import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction_model.dart';
import '../../widgets/notification_bell_button.dart';
import '../../core/services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onProfileTap;
  final void Function(int tabIndex)? onNavigateTab;

  const ProfileScreen({
    super.key,
    this.onHomeTap,
    this.onProfileTap,
    this.onNavigateTab,
  });

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  // Profile Information
  String _userName = '';
  String _userHandle = '';
  String _userEmail = '';
  String _currency = 'USD (\$)';
  int _salaryDay = 25;
  double _monthlyBudget = 1500.0;

  // Toggle Preferences
  bool _isBiometricEnabled = true;
  bool _isBudgetAlertEnabled = true;
  bool _isHapticsEnabled = true;

  // Dynamic Statistics
  int _activePotsCount = 0;
  int _savingsScore = 98;
  int _totalTransactionsCount = 0;


  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// Memuat profil, preferensi, dan statistik dari database SQLite
  Future<void> loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await DbHelper.instance.getUserProfile();
      final budget = await DbHelper.instance.getMonthlyBudget();
      final potsCount = await DbHelper.instance.getSavingsGoalsCount();
      final allTx = await DbHelper.instance.getAllTransactions();

      // Hitung pengeluaran bulan ini untuk skor budget
      final now = DateTime.now();
      double thisMonthExpense = 0;
      for (final tx in allTx) {
        if (tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.type == TransactionType.expense) {
          thisMonthExpense += tx.amount;
        }
      }

      int score = 98;
      if (budget > 0) {
        final ratio = (thisMonthExpense / budget);
        if (ratio <= 0.5) {
          score = 98;
        } else if (ratio <= 0.8) {
          score = 88;
        } else if (ratio <= 1.0) {
          score = 72;
        } else {
          score = ((1.0 - (ratio - 1.0)) * 50).toInt().clamp(10, 60);
        }
      }

      NotificationService.instance.refreshUnreadCount();

      if (mounted) {
        setState(() {
          _userName = profile['user_name'] ?? '';
          _userHandle = profile['user_handle'] ?? '';
          _userEmail = profile['user_email'] ?? '';
          _currency = profile['currency'] ?? 'USD (\$)';
          _salaryDay = int.tryParse(profile['salary_day'] ?? '25') ?? 25;
          _isBiometricEnabled = profile['biometric_enabled'] != 'false';
          _isBudgetAlertEnabled = profile['budget_alert_enabled'] != 'false';
          _isHapticsEnabled = profile['haptics_enabled'] != 'false';
          _monthlyBudget = budget;
          _activePotsCount = potsCount;
          _savingsScore = score;
          _totalTransactionsCount = allTx.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Modal Edit Profil (Nama, Handle, Email) ---
  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _userName);
    final handleCtrl = TextEditingController(text: _userHandle);
    final emailCtrl = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.edit_note_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Edit Profil Pengguna',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  filled: true,
                  fillColor: const Color(0xFFFAF1E8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: handleCtrl,
                decoration: InputDecoration(
                  labelText: 'Username / Handle',
                  filled: true,
                  fillColor: const Color(0xFFFAF1E8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: const Color(0xFFFAF1E8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF757575))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00583A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              final newHandle = handleCtrl.text.trim();
              final newEmail = emailCtrl.text.trim();

              if (newName.isNotEmpty) {
                final messenger = ScaffoldMessenger.of(context);
                await DbHelper.instance.setSetting('user_name', newName);
                if (newHandle.isNotEmpty) {
                  await DbHelper.instance.setSetting('user_handle', newHandle);
                }
                if (newEmail.isNotEmpty) {
                  await DbHelper.instance.setSetting('user_email', newEmail);
                }
                await loadData();
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Profil berhasil diperbarui!'),
                      backgroundColor: Color(0xFF006C49),
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Modal Atur Batas Anggaran Bulanan ---
  void _showMonthlyBudgetBottomSheet() {
    final controller = TextEditingController(text: _monthlyBudget.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.85,
                ),
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8C7BA),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Batas Anggaran Bulanan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFFAF1E8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tetapkan batas limit belanja bulanan. FinLix akan memberikan indikator visual saat mendekati batas ini.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF757575),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (AppFormatters.isIdr
                            ? [500000.0, 1000000.0, 2000000.0, 5000000.0, 10000000.0]
                            : [500.0, 1000.0, 1500.0, 2000.0, 3000.0, 5000.0])
                        .map((amt) {
                      final isSelected = double.tryParse(controller.text) == amt;
                      return ChoiceChip(
                        label: Text(AppFormatters.formatCompact(amt)),
                        selected: isSelected,
                        selectedColor: const Color(0xFFD4EFE1),
                        backgroundColor: const Color(0xFFFAF1E8),
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? const Color(0xFF006C49) : AppColors.onSurface,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF006C49) : const Color(0xFFE2CFC2),
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              controller.text = amt.toStringAsFixed(0);
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        prefixIcon: AppFormatters.isIdr
                            ? const Center(
                                widthFactor: 1.0,
                                heightFactor: 1.0,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 14, right: 6),
                                  child: Text(
                                    'Rp',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : const Icon(Icons.attach_money_rounded, color: AppColors.primary),
                      labelText: 'Nominal Batas Anggaran',
                      filled: true,
                      fillColor: const Color(0xFFFAF1E8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00583A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        final parsed = double.tryParse(controller.text);
                        if (parsed != null && parsed > 0) {
                          final messenger = ScaffoldMessenger.of(context);
                          await DbHelper.instance.setMonthlyBudget(parsed);
                          await loadData();
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Batas anggaran bulanan berhasil disimpan: ${AppFormatters.formatCurrency(parsed)}!'),
                                backgroundColor: const Color(0xFF006C49),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Simpan Anggaran',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
          },
        );
      },
    );
  }

  // --- Modal Pemilih Mata Uang Utama ---
  void _showCurrencyPicker() {
    final currencies = [
      {'code': 'USD (\$)', 'desc': 'Dolar Amerika Serikat (Default)'},
      {'code': 'IDR (Rp)', 'desc': 'Rupiah Indonesia'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8C7BA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pilih Mata Uang Utama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Mata uang default yang digunakan untuk menampilkan laporan saldo dan transaksi.',
                style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: currencies.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFEFE6DD)),
                  itemBuilder: (context, index) {
                    final curr = currencies[index];
                    final isSelected = _currency == curr['code'];
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFD4EFE1) : const Color(0xFFFAF1E8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.monetization_on_outlined,
                            color: isSelected ? const Color(0xFF006C49) : const Color(0xFF6E7A72),
                            size: 22,
                          ),
                        ),
                        title: Text(
                          curr['code']!,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? const Color(0xFF006C49) : AppColors.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          curr['desc']!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF006C49), size: 24)
                            : null,
                        onTap: () async {
                          final selectedCode = curr['code']!;
                          final messenger = ScaffoldMessenger.of(context);
                          if (ctx.mounted) Navigator.pop(ctx);
                          setState(() {
                            _currency = selectedCode;
                          });
                          AppFormatters.setCurrency(selectedCode);
                          await DbHelper.instance.setSetting('currency', selectedCode);
                          await loadData();
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Mata uang utama diubah ke $selectedCode'),
                                backgroundColor: const Color(0xFF006C49),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // --- Modal Pemilih Tanggal Gajian / Awal Periode ---
  void _showSalaryDayPicker() {
    final days = [1, 5, 10, 15, 20, 25, 28, 30];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8C7BA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Awal Periode / Tanggal Gajian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Siklus perhitungan anggaran bulanan akan di-reset pada tanggal yang Anda tentukan.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: days.map((day) {
                    final isSelected = _salaryDay == day;
                    return ChoiceChip(
                      label: Text('Tanggal $day'),
                      selected: isSelected,
                      selectedColor: const Color(0xFFD4EFE1),
                      backgroundColor: const Color(0xFFFAF1E8),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? const Color(0xFF006C49) : AppColors.onSurface,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF006C49) : const Color(0xFFE2CFC2),
                        ),
                      ),
                      onSelected: (selected) async {
                        if (selected) {
                          final messenger = ScaffoldMessenger.of(context);
                          await DbHelper.instance.setSetting('salary_day', day.toString());
                          await loadData();
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Siklus gajian diatur ke tanggal $day tiap bulan.'),
                                backgroundColor: const Color(0xFF006C49),
                              ),
                            );
                          }
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Modal Ganti PIN Keamanan ---
  void _showChangePinDialog() {
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.lock_outline_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Ganti PIN Keamanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan 6 angka PIN baru untuk memproteksi dompet FinLix Anda saat dibuka:',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.primary),
                labelText: 'PIN 6 Digit',
                filled: true,
                fillColor: const Color(0xFFFAF1E8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF757575))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00583A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (pinCtrl.text.trim().length == 6) {
                final messenger = ScaffoldMessenger.of(context);
                await DbHelper.instance.setSetting('user_pin', pinCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('PIN keamanan 6 digit berhasil diaktifkan!'),
                      backgroundColor: Color(0xFF006C49),
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan PIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Modal Backup & Ekspor Data ---
  void _showExportDataModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8C7BA),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: const [
                Icon(Icons.file_download_outlined, color: Color(0xFF006C49), size: 24),
                SizedBox(width: 8),
                Text(
                  'Backup & Ekspor Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Semua catatan transaksi dan target kantong tabungan Anda tersimpan secara offline di database SQLite lokal.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF757575), height: 1.3),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF1E8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Transaksi Tersimpan:', style: TextStyle(fontSize: 12.5, color: Color(0xFF757575))),
                      Text('$_totalTransactionsCount Data', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kantong Tabungan Aktif:', style: TextStyle(fontSize: 12.5, color: Color(0xFF757575))),
                      Text('$_activePotsCount Kantong', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Status Keamanan:', style: TextStyle(fontSize: 12.5, color: Color(0xFF757575))),
                      Text('Terenkripsi Lokal', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006C49))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00583A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.cloud_download_outlined, color: Colors.white, size: 20),
                label: const Text(
                  'Ekspor Ringkasan CSV',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ringkasan data berhasil disiapkan untuk diunduh!'),
                      backgroundColor: Color(0xFF006C49),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  // --- Modal FAQ & Panduan ---
  void _showFaqModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.65,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8C7BA),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: const [
                Icon(Icons.help_outline_rounded, color: Color(0xFF006C49)),
                SizedBox(width: 8),
                Text(
                  'Pusat Bantuan & FAQ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: const [
                  _FaqTile(
                    question: 'Bagaimana cara mengatur batas anggaran bulanan?',
                    answer: 'Buka tab Profile > Pengaturan Finansial > Batas Anggaran Bulanan. Pilih nominal cepat atau ketik target budget bulanan yang Anda inginkan.',
                  ),
                  _FaqTile(
                    question: 'Apakah data FinLix aman?',
                    answer: 'Sangat aman! FinLix menggunakan pendekatan Offline-First dengan database SQLite lokal. Tidak ada data pribadi atau nominal saldo Anda yang dikirim ke server luar.',
                  ),
                  _FaqTile(
                    question: 'Bagaimana cara kerja Kantong (Pots)?',
                    answer: 'Kantong memungkinkan Anda menyisihkan dana untuk tujuan khusus (misal liburan atau dana darurat) terpisah dari saldo harian.',
                  ),
                  _FaqTile(
                    question: 'Apakah saya bisa mengubah tanggal siklus gajian?',
                    answer: 'Bisa! Buka opsi "Awal Periode / Gajian" di profil Anda, lalu tentukan tanggal gajian Anda untuk me-reset grafik bulanan secara otomatis.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Modal Privasi ---
  void _showPrivacyModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.shield_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Kebijakan Privasi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: const Text(
          'FinLix dibangun dengan prinsip Privasi Mutlak (Zero-Knowledge / Offline-First). Seluruh data keuangan, transaksi, dan target kantong disimpan secara eksklusif pada penyimpanan lokal perangkat Anda via SQLite.\n\nKami tidak melacak riwayat transaksi Anda atau menjual data kepada pihak ketiga.',
          style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF6E7A72)),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00583A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Modal Konfirmasi Reset Seluruh Data Akun ---
  void _showResetAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.restart_alt_rounded, color: Color(0xFFC05621)),
            SizedBox(width: 8),
            Text('Reset Semua Data?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Tindakan ini akan menghapus seluruh catatan transaksi, kantong tabungan impian, dan mengembalikan setelan aplikasi ke kondisi awal seperti baru diinstal.\n\nApakah Anda yakin ingin melanjutkan?',
          style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF757575))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBD382B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await DbHelper.instance.resetAllData();
              AppFormatters.setCurrency('USD (\$)');
              await loadData();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Seluruh data akun berhasil di-reset ke kondisi awal!'),
                    backgroundColor: Color(0xFF006C49),
                  ),
                );
              }
            },
            child: const Text('Ya, Reset Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Modal Konfirmasi Keluar / Reset ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: Color(0xFFBD382B)),
            SizedBox(width: 8),
            Text('Keluar Akun FinLix?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Sesi profil aktif Anda akan ditutup. Tenang saja, semua catatan transaksi dan tabungan SQLite tetap aman tersimpan di perangkat ini.',
          style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF757575))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBD382B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Berhasil keluar dari akun lokal.'),
                  backgroundColor: Color(0xFFBD382B),
                ),
              );
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            // App Logo Icon (Wallet -> Home)
            Tooltip(
              message: 'Home',
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: widget.onHomeTap,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7F0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFCBEBD8),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFF006C49),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'FINLIX',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Color(0xFF757575),
                  ),
                ),
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Notification Bell Button
          NotificationBellButton(onNavigateTab: widget.onNavigateTab),
          const SizedBox(width: 8),

          // Profile Avatar (Tap -> Profile)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Tooltip(
              message: 'Profile',
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    if (widget.onProfileTap != null) {
                      widget.onProfileTap!();
                    } else {
                      _showEditProfileDialog();
                    }
                  },
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: const Color(0xFFD4EFE1),
                    child: const CircleAvatar(
                      radius: 17,
                      backgroundColor: Color(0xFFFFDED4),
                      child: Icon(
                        Icons.person_rounded,
                        size: 22,
                        color: Color(0xFF8E4C3B),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Profile Card (Interactive)
                      _buildUserProfileCard(),
                      const SizedBox(height: 12),

                      // Membership Banner Card
                      _buildMembershipBanner(),
                      const SizedBox(height: 20),

                      // Section 1: AKUN & KEAMANAN
                      _buildSectionTitle('AKUN & KEAMANAN'),
                      const SizedBox(height: 8),
                      _buildGroupCard([
                        _buildSettingsTile(
                          icon: Icons.mail_outline_rounded,
                          title: 'Email Terdaftar',
                          subtitle: _userEmail,
                          onTap: _showEditProfileDialog,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4EFE1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Terverifikasi',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF006C49),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                            ],
                          ),
                        ),
                        _buildSwitchTile(
                          icon: Icons.fingerprint_rounded,
                          title: 'Kunci Biometrik / Face ID',
                          subtitle: 'Amankan dompet saat dibuka',
                          value: _isBiometricEnabled,
                          onChanged: (val) async {
                            setState(() => _isBiometricEnabled = val);
                            await DbHelper.instance.setSetting('biometric_enabled', val.toString());
                          },
                        ),
                        _buildSettingsTile(
                          icon: Icons.password_rounded,
                          title: 'Ganti PIN FinLix',
                          subtitle: '6 digit keamanan transaksi',
                          onTap: _showChangePinDialog,
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // Section 2: PENGATURAN FINANSIAL
                      _buildSectionTitle('PENGATURAN FINANSIAL'),
                      const SizedBox(height: 8),
                      _buildGroupCard([
                        // Batas Anggaran Bulanan
                        _buildSettingsTile(
                          icon: Icons.savings_outlined,
                          title: 'Batas Anggaran Bulanan',
                          subtitle: 'Target maksimal belanja per bulan',
                          onTap: _showMonthlyBudgetBottomSheet,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppFormatters.formatCurrency(_monthlyBudget),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF006C49),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                            ],
                          ),
                        ),
                        // Mata Uang Utama
                        _buildSettingsTile(
                          icon: Icons.payments_outlined,
                          title: 'Mata Uang Utama',
                          subtitle: 'Format penulisan saldo',
                          onTap: _showCurrencyPicker,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currency,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                            ],
                          ),
                        ),
                        // Awal Periode / Gajian
                        _buildSettingsTile(
                          icon: Icons.calendar_month_outlined,
                          title: 'Awal Periode / Gajian',
                          subtitle: 'Reset anggaran bulanan',
                          onTap: _showSalaryDayPicker,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Tgl $_salaryDay Tiap\nBulan',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                            ],
                          ),
                        ),
                        _buildSwitchTile(
                          icon: Icons.notifications_active_outlined,
                          title: 'Peringatan Budget 80%',
                          subtitle: 'Notif santai saat mendekati batas',
                          value: _isBudgetAlertEnabled,
                          onChanged: (val) async {
                            setState(() => _isBudgetAlertEnabled = val);
                            await DbHelper.instance.setSetting('budget_alert_enabled', val.toString());
                          },
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // Section 3: KUSTOMISASI & TAMPILAN
                      _buildSectionTitle('KUSTOMISASI & TAMPILAN'),
                      const SizedBox(height: 8),
                      _buildGroupCard([
                        _buildSettingsTile(
                          icon: Icons.palette_outlined,
                          title: 'Tema Aplikasi',
                          subtitle: 'Nuansa visual antarmuka',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tema Warm Peach aktif secara default untuk kenyamanan mata.'),
                                backgroundColor: Color(0xFF006C49),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0E6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFF3D5C8), width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFB5A2),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Warm\nPeach',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                            ],
                          ),
                        ),
                        _buildSwitchTile(
                          icon: Icons.vibration_rounded,
                          title: 'Sentuhan Haptik & Suara',
                          subtitle: 'Sensasi klik koin kerikil',
                          value: _isHapticsEnabled,
                          onChanged: (val) async {
                            setState(() => _isHapticsEnabled = val);
                            await DbHelper.instance.setSetting('haptics_enabled', val.toString());
                          },
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // Section 4: DATA & BANTUAN
                      _buildSectionTitle('DATA & BANTUAN'),
                      const SizedBox(height: 8),
                      _buildGroupCard([
                        _buildSettingsTile(
                          icon: Icons.file_download_outlined,
                          title: 'Backup & Ekspor Data',
                          subtitle: 'Unduh riwayat transaksi offline SQLite',
                          onTap: _showExportDataModal,
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                        ),
                        _buildSettingsTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Pusat Bantuan & FAQ',
                          subtitle: 'Panduan penggunaan & tips hemat',
                          onTap: _showFaqModal,
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                        ),
                        _buildSettingsTile(
                          icon: Icons.shield_outlined,
                          title: 'Kebijakan Privasi',
                          subtitle: 'Enkripsi data pribadi offline-first',
                          onTap: _showPrivacyModal,
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                        ),
                      ]),
                      const SizedBox(height: 22),

                      // Reset Data Akun Button
                      InkWell(
                        onTap: _showResetAccountDialog,
                        borderRadius: BorderRadius.circular(20),
                        child: _buildResetButton(),
                      ),
                      const SizedBox(height: 12),

                      // Keluar Akun Button
                      InkWell(
                        onTap: _showLogoutDialog,
                        borderRadius: BorderRadius.circular(20),
                        child: _buildLogoutButton(),
                      ),
                      const SizedBox(height: 16),

                      // Version & Footer Text
                      _buildFooterInfo(),

                      // Bottom padding for floating navigation bar
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildUserProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2EB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // Avatar + User Info + Edit Button
          Row(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFD4EFE1),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFFFFDED4),
                      child: Icon(
                        Icons.person_rounded,
                        size: 34,
                        color: Color(0xFF8E4C3B),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF006C49),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Name and Handle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4EFE1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.stars_rounded, size: 12, color: Color(0xFF006C49)),
                              SizedBox(width: 2),
                              Text(
                                'Plus',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF006C49),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_userHandle • FinLix Member',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Pencil Button
              InkWell(
                onTap: _showEditProfileDialog,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFECE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.onSurface,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Dynamic Stats Boxes
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  value: '$_activePotsCount Kantong',
                  label: 'Pots Aktif',
                  valueColor: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBox(
                  value: '142 Hari',
                  label: 'Streak Hemat',
                  valueColor: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBox(
                  value: '$_savingsScore%',
                  label: 'Skor Budget',
                  valueColor: const Color(0xFF006C49),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF1E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF0DDD0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2EB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFE2A03F),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'FinLix Plus Aktif',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Auto-kategorisasi & database offline SQLite',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Color(0xFF8E9A92),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: Color(0xFF757575),
      ),
    );
  }

  Widget _buildGroupCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF1E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final bool isLast = index == items.length - 1;
          return Column(
            children: [
              items[index],
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.divider,
                  indent: 14,
                  endIndent: 14,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E6DA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF6E7A72),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E6DA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6E7A72),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 26,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: value ? const Color(0xFF006C49) : const Color(0xFFE2CFC2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Align(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 21,
                  height: 21,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECE5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFCCD0),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.logout_rounded,
            color: Color(0xFFBD382B),
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Keluar Akun',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD382B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFDEC9),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.restart_alt_rounded,
            color: Color(0xFFC05621),
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Reset Data Akun',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFC05621),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Center(
      child: Column(
        children: const [
          Text(
            'FinLix v2.4.0 (Flutter Release)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E9A92),
            ),
          ),
          SizedBox(height: 3),
          Text(
            'Dibuat dengan rasa tenang untuk finansialmu',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF8E9A92),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF1E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6E7A72),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
