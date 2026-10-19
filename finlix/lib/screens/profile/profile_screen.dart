import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/database/db_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../../models/transaction_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  // Profile Information
  String _userName = 'Alex Rivera';
  String _userHandle = '@alexfinances';
  String _userEmail = 'alex.rivera@example.com';
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

  final NumberFormat _currencyFormatter = NumberFormat('#,##0.00', 'en_US');

  String _formatAmount(double amount) {
    return _currencyFormatter.format(amount);
  }

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

      if (mounted) {
        setState(() {
          _userName = profile['user_name'] ?? 'Alex Rivera';
          _userHandle = profile['user_handle'] ?? '@alexfinances';
          _userEmail = profile['user_email'] ?? 'alex.rivera@example.com';
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
          children: [
            const Icon(Icons.edit_note_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              AppLanguage.tr('edit_profile_title'),
              style: const TextStyle(
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
                  labelText: AppLanguage.tr('full_name'),
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
                  labelText: AppLanguage.tr('username_handle'),
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
            child: Text(AppLanguage.tr('cancel'), style: const TextStyle(color: Color(0xFF757575))),
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
                    SnackBar(
                      content: Text(AppLanguage.tr('profile_updated_toast')),
                      backgroundColor: const Color(0xFF006C49),
                    ),
                  );
                }
              }
            },
            child: Text(AppLanguage.tr('save'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      Text(
                        AppLanguage.tr('set_budget_title'),
                        style: const TextStyle(
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
                  Text(
                    AppLanguage.tr('set_budget_desc'),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF757575),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [500.0, 1000.0, 1500.0, 2000.0, 3000.0, 5000.0].map((amt) {
                      final isSelected = double.tryParse(controller.text) == amt;
                      return ChoiceChip(
                        label: Text('\$${amt.toStringAsFixed(0)}'),
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
                      prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.primary),
                      labelText: AppLanguage.tr('budget_amount'),
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
                                content: Text('${AppLanguage.tr('budget_saved_toast')}: \$${_formatAmount(parsed)}!'),
                                backgroundColor: const Color(0xFF006C49),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        AppLanguage.tr('save_budget'),
                        style: const TextStyle(
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
      {'code': 'USD (\$)', 'desc': AppLanguage.tr('currency_usd_desc')},
      {'code': 'IDR (Rp)', 'desc': AppLanguage.tr('currency_idr_desc')},
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
              Text(
                AppLanguage.tr('select_currency_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLanguage.tr('select_currency_desc'),
                style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 16),
              ...currencies.map((curr) {
                final isSelected = _currency == curr['code'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () async {
                      final selectedCode = curr['code']!;
                      final messenger = ScaffoldMessenger.of(context);
                      if (ctx.mounted) Navigator.pop(ctx);
                      setState(() {
                        _currency = selectedCode;
                      });
                      await DbHelper.instance.setSetting('currency', selectedCode);
                      await loadData();
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('${AppLanguage.tr('currency_changed_toast')} $selectedCode'),
                            backgroundColor: const Color(0xFF006C49),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE8F7EE) : const Color(0xFFFAF1E8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF006C49) : const Color(0xFFEFE6DD),
                          width: isSelected ? 1.6 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFD4EFE1) : const Color(0xFFF3E7DC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.monetization_on_outlined,
                              color: isSelected ? const Color(0xFF006C49) : const Color(0xFF6E7A72),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  curr['code']!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? const Color(0xFF006C49) : AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  curr['desc']!,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF006C49),
                              size: 24,
                            )
                          else
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFD8C7BA), width: 1.5),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // --- Modal Pemilih Bahasa Aplikasi ---
  void _showLanguagePicker() {
    final languages = [
      {'code': 'id', 'name': 'Bahasa Indonesia', 'desc': 'Bahasa Indonesia (Default)'},
      {'code': 'en', 'name': 'English', 'desc': 'English (United States)'},
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
              Text(
                AppLanguage.tr('select_language_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLanguage.tr('select_language_desc'),
                style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 16),
              ...languages.map((lang) {
                final isSelected = AppLanguage.instance.currentCode == lang['code'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () async {
                      final selectedCode = lang['code']!;
                      final messenger = ScaffoldMessenger.of(context);
                      if (ctx.mounted) Navigator.pop(ctx);
                      await AppLanguage.instance.setLanguage(selectedCode);
                      if (mounted) {
                        setState(() {});
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('${AppLanguage.tr('language_changed_toast')} ${lang['name']}'),
                            backgroundColor: const Color(0xFF006C49),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE8F7EE) : const Color(0xFFFAF1E8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF006C49) : const Color(0xFFEFE6DD),
                          width: isSelected ? 1.6 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFD4EFE1) : const Color(0xFFF3E7DC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.translate_rounded,
                              color: isSelected ? const Color(0xFF006C49) : const Color(0xFF6E7A72),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang['name']!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? const Color(0xFF006C49) : AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lang['desc']!,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF006C49),
                              size: 24,
                            )
                          else
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFD8C7BA), width: 1.5),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
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
                Text(
                  AppLanguage.tr('salary_day_title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLanguage.tr('salary_day_instruction'),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: days.map((day) {
                    final isSelected = _salaryDay == day;
                    return ChoiceChip(
                      label: Text(AppLanguage.instance.isIndonesian ? 'Tanggal $day' : 'Day $day'),
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
                                content: Text(
                                  AppLanguage.instance.isIndonesian
                                      ? 'Siklus gajian diatur ke tanggal $day tiap bulan.'
                                      : 'Salary cycle set to day $day monthly.',
                                ),
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
          children: [
            const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              AppLanguage.tr('change_pin_title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLanguage.tr('change_pin_instruction'),
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.primary),
                labelText: AppLanguage.tr('pin_field_label'),
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
            child: Text(AppLanguage.tr('cancel'), style: const TextStyle(color: Color(0xFF757575))),
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
                    SnackBar(
                      content: Text(AppLanguage.tr('pin_saved_toast')),
                      backgroundColor: const Color(0xFF006C49),
                    ),
                  );
                }
              }
            },
            child: Text(AppLanguage.tr('save_pin_btn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              children: [
                const Icon(Icons.file_download_outlined, color: Color(0xFF006C49), size: 24),
                const SizedBox(width: 8),
                Text(
                  AppLanguage.tr('backup_export_title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppLanguage.tr('backup_export_desc_full'),
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF757575), height: 1.3),
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
                      Text(AppLanguage.tr('total_stored_tx'), style: const TextStyle(fontSize: 12.5, color: Color(0xFF757575))),
                      Text('$_totalTransactionsCount ${AppLanguage.instance.isIndonesian ? "Data" : "Records"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLanguage.tr('active_pots_count_label'), style: const TextStyle(fontSize: 12.5, color: Color(0xFF757575))),
                      Text('$_activePotsCount ${AppLanguage.instance.isIndonesian ? "Kantong" : "Pots"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLanguage.tr('security_status_label'), style: const TextStyle(fontSize: 12.5, color: Color(0xFF757575))),
                      Text(AppLanguage.tr('locally_encrypted'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006C49))),
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
                label: Text(
                  AppLanguage.tr('export_csv_btn'),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLanguage.tr('export_csv_toast')),
                      backgroundColor: const Color(0xFF006C49),
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
              children: [
                const Icon(Icons.help_outline_rounded, color: Color(0xFF006C49)),
                const SizedBox(width: 8),
                Text(
                  AppLanguage.tr('faq_help_label'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _FaqTile(
                    question: AppLanguage.instance.isIndonesian
                        ? 'Bagaimana cara mengatur batas anggaran bulanan?'
                        : 'How to set a monthly spending budget?',
                    answer: AppLanguage.instance.isIndonesian
                        ? 'Buka tab Profile > Pengaturan Finansial > Batas Anggaran Bulanan. Pilih nominal cepat atau ketik target budget bulanan yang Anda inginkan.'
                        : 'Open Profile tab > Financial Settings > Monthly Budget. Choose a quick preset or type your custom monthly limit.',
                  ),
                  _FaqTile(
                    question: AppLanguage.instance.isIndonesian
                        ? 'Apakah data FinLix aman?'
                        : 'Is my data safe on FinLix?',
                    answer: AppLanguage.instance.isIndonesian
                        ? 'Sangat aman! FinLix menggunakan pendekatan Offline-First dengan database SQLite lokal. Tidak ada data pribadi atau nominal saldo Anda yang dikirim ke server luar.'
                        : '100% private! FinLix employs an Offline-First approach with local SQLite storage. No balance or transaction details ever leave your device.',
                  ),
                  _FaqTile(
                    question: AppLanguage.instance.isIndonesian
                        ? 'Bagaimana cara kerja Kantong (Pots)?'
                        : 'How do Savings Pots work?',
                    answer: AppLanguage.instance.isIndonesian
                        ? 'Kantong memungkinkan Anda menyisihkan dana untuk tujuan khusus (misal liburan atau dana darurat) terpisah dari saldo harian.'
                        : 'Pots let you separate savings goals (vacation, emergency fund, gadgets) from your daily spending cash.',
                  ),
                  _FaqTile(
                    question: AppLanguage.instance.isIndonesian
                        ? 'Apakah saya bisa mengubah tanggal siklus gajian?'
                        : 'Can I change my salary cycle date?',
                    answer: AppLanguage.instance.isIndonesian
                        ? 'Bisa! Buka opsi "Awal Periode / Gajian" di profil Anda, lalu tentukan tanggal gajian Anda untuk me-reset grafik bulanan secara otomatis.'
                        : 'Yes! Tap "Salary Day / Cycle" in your profile and select your payday to automatically reset monthly analytics.',
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
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(AppLanguage.tr('privacy_policy_title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: Text(
          AppLanguage.tr('privacy_policy_body'),
          style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF6E7A72)),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00583A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLanguage.tr('understood_btn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFBD382B)),
            const SizedBox(width: 8),
            Text(AppLanguage.tr('logout_confirm_title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: Text(
          AppLanguage.tr('logout_confirm_desc'),
          style: const TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLanguage.tr('cancel'), style: const TextStyle(color: Color(0xFF757575))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBD382B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLanguage.tr('logout_success_toast')),
                  backgroundColor: const Color(0xFFBD382B),
                ),
              );
            },
            child: Text(AppLanguage.tr('logout_button'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            // App Logo Icon
            Container(
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
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'FINLIX',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Color(0xFF757575),
                  ),
                ),
                Text(
                  AppLanguage.tr('nav_profile'),
                  style: const TextStyle(
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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFECE5),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFF3D5C8),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.onSurface,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),

          // Profile Avatar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
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
                      _buildSectionTitle(AppLanguage.tr('sec_account_security')),
                      const SizedBox(height: 8),
                      _buildGroupCard([
                        _buildSettingsTile(
                          icon: Icons.mail_outline_rounded,
                          title: AppLanguage.tr('registered_email'),
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
                                child: Text(
                                  AppLanguage.tr('verified_badge'),
                                  style: const TextStyle(
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
                          title: AppLanguage.tr('biometric_face_id'),
                          subtitle: AppLanguage.tr('biometric_secure_desc'),
                          value: _isBiometricEnabled,
                          onChanged: (val) async {
                            setState(() => _isBiometricEnabled = val);
                            await DbHelper.instance.setSetting('biometric_enabled', val.toString());
                          },
                        ),
                        _buildSettingsTile(
                          icon: Icons.password_rounded,
                          title: AppLanguage.tr('change_finlix_pin'),
                          subtitle: AppLanguage.tr('pin_security_desc'),
                          onTap: _showChangePinDialog,
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // Section 2: PENGATURAN FINANSIAL
                      _buildSectionTitle(AppLanguage.tr('sec_financial_settings')),
                      const SizedBox(height: 8),
                      _buildGroupCard([
                        // Batas Anggaran Bulanan
                        _buildSettingsTile(
                          icon: Icons.savings_outlined,
                          title: AppLanguage.tr('monthly_budget_label'),
                          subtitle: AppLanguage.tr('monthly_budget_sub'),
                          onTap: _showMonthlyBudgetBottomSheet,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${_formatAmount(_monthlyBudget)}',
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
                          title: AppLanguage.tr('main_currency_label'),
                          subtitle: AppLanguage.tr('currency_sub'),
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
                          title: AppLanguage.tr('salary_period_label'),
                          subtitle: AppLanguage.tr('salary_period_sub'),
                          onTap: _showSalaryDayPicker,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLanguage.instance.isIndonesian
                                    ? 'Tgl $_salaryDay Tiap\nBulan'
                                    : 'Day $_salaryDay\nMonthly',
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
                          title: AppLanguage.tr('budget_alert_label'),
                          subtitle: AppLanguage.tr('budget_alert_sub'),
                          value: _isBudgetAlertEnabled,
                          onChanged: (val) async {
                            setState(() => _isBudgetAlertEnabled = val);
                            await DbHelper.instance.setSetting('budget_alert_enabled', val.toString());
                          },
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // Section 3: PREFERENSI & TAMPILAN
                      _buildSectionTitle(AppLanguage.tr('sec_preferences_display')),
                      const SizedBox(height: 8),
                      _buildGroupCard([
                        // Bahasa Aplikasi / App Language
                        _buildSettingsTile(
                          icon: Icons.language_rounded,
                          title: AppLanguage.tr('app_language'),
                          subtitle: AppLanguage.tr('app_language_desc'),
                          onTap: _showLanguagePicker,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLanguage.instance.isIndonesian ? 'Indonesia' : 'English',
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
                        _buildSettingsTile(
                          icon: Icons.palette_outlined,
                          title: AppLanguage.tr('theme_label'),
                          subtitle: AppLanguage.tr('theme_sub'),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLanguage.tr('theme_snack')),
                                backgroundColor: const Color(0xFF006C49),
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
                          title: AppLanguage.tr('haptics_touch_label'),
                          subtitle: AppLanguage.tr('haptics_touch_sub'),
                          value: _isHapticsEnabled,
                          onChanged: (val) async {
                            setState(() => _isHapticsEnabled = val);
                            await DbHelper.instance.setSetting('haptics_enabled', val.toString());
                          },
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // Section 4: DATA & BANTUAN
                      _buildSectionTitle(AppLanguage.tr('sec_data_help')),
                      const SizedBox(height: 8),
                      _buildGroupCard([
                        _buildSettingsTile(
                          icon: Icons.file_download_outlined,
                          title: AppLanguage.tr('backup_export_label'),
                          subtitle: AppLanguage.tr('backup_export_sub'),
                          onTap: _showExportDataModal,
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                        ),
                        _buildSettingsTile(
                          icon: Icons.help_outline_rounded,
                          title: AppLanguage.tr('faq_help_label'),
                          subtitle: AppLanguage.tr('faq_help_sub'),
                          onTap: _showFaqModal,
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                        ),
                        _buildSettingsTile(
                          icon: Icons.shield_outlined,
                          title: AppLanguage.tr('privacy_policy_label'),
                          subtitle: AppLanguage.tr('privacy_policy_sub'),
                          onTap: _showPrivacyModal,
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF8E9A92)),
                        ),
                      ]),
                      const SizedBox(height: 22),

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
                      '$_userHandle • ${AppLanguage.tr('member_badge')}',
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
                  value: '$_activePotsCount ${_activePotsCount == 1 ? AppLanguage.tr('pot_unit_single') : AppLanguage.tr('pots_unit')}',
                  label: AppLanguage.tr('active_pots_stat'),
                  valueColor: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBox(
                  value: '142 ${AppLanguage.tr('days_unit')}',
                  label: AppLanguage.tr('saving_streak_label'),
                  valueColor: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBox(
                  value: '$_savingsScore%',
                  label: AppLanguage.tr('budget_score_label'),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF757575),
              ),
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
              children: [
                Text(
                  AppLanguage.tr('plus_active'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLanguage.tr('plus_desc'),
                  style: const TextStyle(
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
        children: [
          const Icon(
            Icons.logout_rounded,
            color: Color(0xFFBD382B),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            AppLanguage.tr('logout_button'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBD382B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Center(
      child: Column(
        children: [
          const Text(
            'FinLix v2.4.0 (Flutter Release)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E9A92),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            AppLanguage.tr('footer_peace'),
            style: const TextStyle(
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
