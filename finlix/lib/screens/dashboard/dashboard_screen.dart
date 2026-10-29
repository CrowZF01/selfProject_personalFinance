import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/data/default_categories.dart';
import '../../core/database/db_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction_model.dart';
import '../../widgets/notification_bell_button.dart';
import '../../core/services/notification_service.dart';
import '../transactions/add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onProfileTap;
  final void Function(int tabIndex)? onNavigateTab;

  const DashboardScreen({
    super.key,
    this.onHomeTap,
    this.onProfileTap,
    this.onNavigateTab,
  });

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  DateTime? _selectedDate;
  bool? _isDaySpecific;

  TextEditingController? _searchController;
  TextEditingController get _effectiveSearchController =>
      _searchController ??= TextEditingController();

  TransactionType? _selectedTypeFilter;
  String? _selectedCategoryId;
  bool? _searchAllPeriod;
  bool get _isSearchAllPeriod => _searchAllPeriod ?? false;

  DateTime get selectedDate => _selectedDate ?? DateTime.now();
  bool get isDaySpecific => _isDaySpecific ?? false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _isDaySpecific = false;
    _searchController = TextEditingController();
    _searchAllPeriod = false;
    loadData();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await DbHelper.instance.getAllTransactions();
      NotificationService.instance.refreshUnreadCount();
      if (mounted) {
        setState(() {
          _transactions = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _selectedDate ??= DateTime.now();
    _isDaySpecific ??= false;
    final curDate = selectedDate;
    final daySpecific = isDaySpecific;

    final String query = _effectiveSearchController.text.trim().toLowerCase();
    final bool isSearching = query.isNotEmpty;
    final bool isFiltering = isSearching ||
        _selectedTypeFilter != null ||
        _selectedCategoryId != null;

    // Ringkasan bulanan (overview saldo bulan terpilih)
    final monthlyTransactions = _transactions.where((tx) {
      if (daySpecific) {
        return tx.date.year == curDate.year &&
            tx.date.month == curDate.month &&
            tx.date.day == curDate.day;
      } else {
        return tx.date.year == curDate.year &&
            tx.date.month == curDate.month;
      }
    }).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    for (var tx in monthlyTransactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }
    final double balance = totalIncome - totalExpense;

    // Filter transaksi berdasarkan pencarian, tipe, kategori, dan periode
    final filteredTransactions = _transactions.where((tx) {
      // 1. Filter tanggal / periode (jika aktif mode cari semua periode saat mencari, lewati filter tanggal)
      if (!(_isSearchAllPeriod && isSearching)) {
        if (daySpecific) {
          final matchDate = tx.date.year == curDate.year &&
              tx.date.month == curDate.month &&
              tx.date.day == curDate.day;
          if (!matchDate) return false;
        } else {
          final matchMonth = tx.date.year == curDate.year &&
              tx.date.month == curDate.month;
          if (!matchMonth) return false;
        }
      }

      // 2. Filter tipe transaksi
      if (_selectedTypeFilter != null && tx.type != _selectedTypeFilter) {
        return false;
      }

      // 3. Filter kategori
      if (_selectedCategoryId != null && tx.categoryId != _selectedCategoryId) {
        return false;
      }

      // 4. Pencarian kata kunci (nama transaksi, catatan, atau kategori)
      if (isSearching) {
        final cat = DefaultCategories.byId(tx.categoryId);
        final titleMatch = tx.title.toLowerCase().contains(query);
        final noteMatch = tx.note?.toLowerCase().contains(query) ?? false;
        final catMatch = cat?.name.toLowerCase().contains(query) ?? false;
        if (!titleMatch && !noteMatch && !catMatch) {
          return false;
        }
      }

      return true;
    }).toList();

    // Group transactions by Date String (e.g. '16 Sept Wednesday')
    final Map<String, List<TransactionModel>> grouped = {};
    for (var tx in filteredTransactions) {
      final dateKey = (tx.date.year == DateTime.now().year)
          ? DateFormat('d MMM EEEE').format(tx.date)
          : DateFormat('d MMM yyyy EEEE').format(tx.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(tx);
    }

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
                      color: AppColors.mintAccentBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.mintAccentBorder,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
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
                  'Home',
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
                  onTap: widget.onProfileTap,
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: AppColors.mintAccentBg,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.peachAccentBg,
                      child: Icon(
                        Icons.person_rounded,
                        size: 22,
                        color: AppColors.primary,
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
          ? Center(
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
                      // Monthly Summary Card
                      _buildMonthlySummaryCard(
                        expenses: AppFormatters.formatCurrency(totalExpense),
                        income: AppFormatters.formatCurrency(totalIncome),
                        balance: AppFormatters.formatCurrency(balance),
                      ),
                      if (daySpecific) ...[
                        const SizedBox(height: 10),
                        _buildFilterActiveBanner(),
                      ],
                      const SizedBox(height: 16),

                      // Search & Quick Filter Controls
                      _buildSearchAndFilterSection(isFiltering, filteredTransactions.length),
                      const SizedBox(height: 14),

                      if (filteredTransactions.isEmpty)
                        _buildEmptyState(isFiltering: isFiltering)
                      else
                        ...grouped.entries.map((entry) {
                          double groupExpense = 0;
                          double groupIncome = 0;
                          for (var item in entry.value) {
                            if (item.type == TransactionType.expense) {
                              groupExpense += item.amount;
                            } else {
                              groupIncome += item.amount;
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildDateSection(
                              dateTitle: entry.key,
                              expensesText: groupExpense > 0 ? AppFormatters.formatCurrency(groupExpense) : AppFormatters.formatCurrency(0),
                              incomeText: groupIncome > 0 ? AppFormatters.formatCurrency(groupIncome) : null,
                              items: entry.value,
                            ),
                          );
                        }),

                      // Bottom padding to avoid overlapping floating nav bar
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFilterActiveBanner() {
    final curDate = selectedDate;
    final dateStr = DateFormat('d MMMM yyyy').format(curDate);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFCBEBD8),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 15,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter: $dateStr',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              setState(() {
                _isDaySpecific = false;
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFCBEBD8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lihat Sebulan',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.close_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required bool isFiltering}) {
    final curDate = selectedDate;
    final daySpecific = isDaySpecific;
    final String titleText;
    final String subtitleText;

    if (isFiltering) {
      titleText = 'Tidak ada transaksi yang cocok';
      subtitleText = 'Tidak ditemukan transaksi sesuai kata kunci atau kriteria filter yang Anda pilih.';
    } else if (_transactions.isEmpty) {
      titleText = 'Belum ada transaksi';
      subtitleText = 'Tekan tombol + di bawah untuk mencatat pengeluaran atau pemasukan baru Anda.';
    } else if (daySpecific) {
      final dateStr = DateFormat('d MMMM yyyy').format(curDate);
      titleText = 'Tidak ada transaksi pada $dateStr';
      subtitleText = 'Tidak ditemukan catatan keuangan di tanggal ini. Coba pilih tanggal atau bulan lain.';
    } else {
      final monthStr = DateFormat('MMMM yyyy').format(curDate);
      titleText = 'Tidak ada transaksi di $monthStr';
      subtitleText = 'Belum ada catatan keuangan di bulan ini. Coba pilih bulan lain atau catat transaksi baru.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isFiltering ? const Color(0xFFE8F7F0) : const Color(0xFFFFDED4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFiltering ? Icons.search_off_rounded : Icons.receipt_long_outlined,
              size: 38,
              color: isFiltering ? AppColors.primary : const Color(0xFF8E4C3B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            titleText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitleText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF757575),
              height: 1.4,
            ),
          ),
          if (isFiltering) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
              ),
              onPressed: _resetAllFilters,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text(
                'Reset Filter & Pencarian',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ] else if (_transactions.isNotEmpty &&
              (daySpecific ||
                  curDate.month != DateTime.now().month ||
                  curDate.year != DateTime.now().year)) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime.now();
                  _isDaySpecific = false;
                });
              },
              icon: Icon(Icons.restore_rounded, size: 16, color: AppColors.primary),
              label: Text(
                'Kembali ke Bulan Sekarang',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.mintAccentBg,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Search & Filter Controls Widget ---
  Widget _buildSearchAndFilterSection(bool isFiltering, int resultCount) {
    final selectedCat = _selectedCategoryId != null
        ? DefaultCategories.byId(_selectedCategoryId!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Search Bar
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _effectiveSearchController.text.isNotEmpty
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.borderSubtle,
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(
                Icons.search_rounded,
                size: 20,
                color: _effectiveSearchController.text.isNotEmpty ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _effectiveSearchController,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari nama transaksi, catatan, atau kategori...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (_effectiveSearchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                  onPressed: () {
                    _effectiveSearchController.clear();
                    setState(() {});
                  },
                ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2. Horizontal Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // Type: Semua
              _buildFilterChip(
                label: 'Semua',
                isSelected: _selectedTypeFilter == null,
                onTap: () {
                  setState(() => _selectedTypeFilter = null);
                },
              ),
              const SizedBox(width: 8),

              // Type: Pengeluaran
              _buildFilterChip(
                label: 'Pengeluaran',
                icon: Icons.arrow_downward_rounded,
                isSelected: _selectedTypeFilter == TransactionType.expense,
                activeColor: AppColors.expense,
                onTap: () {
                  setState(() {
                    _selectedTypeFilter = (_selectedTypeFilter == TransactionType.expense)
                        ? null
                        : TransactionType.expense;
                  });
                },
              ),
              const SizedBox(width: 8),

              // Type: Pemasukan
              _buildFilterChip(
                label: 'Pemasukan',
                icon: Icons.arrow_upward_rounded,
                isSelected: _selectedTypeFilter == TransactionType.income,
                activeColor: AppColors.income,
                onTap: () {
                  setState(() {
                    _selectedTypeFilter = (_selectedTypeFilter == TransactionType.income)
                        ? null
                        : TransactionType.income;
                  });
                },
              ),
              const SizedBox(width: 8),

              // Category Filter Button
              _buildFilterChip(
                label: selectedCat != null ? selectedCat.name : 'Kategori',
                icon: selectedCat != null ? selectedCat.icon : Icons.tune_rounded,
                isSelected: selectedCat != null,
                activeColor: AppColors.primary,
                trailing: selectedCat != null
                    ? GestureDetector(
                        onTap: () => setState(() => _selectedCategoryId = null),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Icon(Icons.close_rounded, size: 14),
                        ),
                      )
                    : const Icon(Icons.arrow_drop_down_rounded, size: 18),
                onTap: _showCategoryFilterModal,
              ),

              // Search All Period Toggle (hanya muncul saat mencari kata kunci)
              if (_effectiveSearchController.text.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _isSearchAllPeriod ? 'Semua Periode' : 'Bulan Ini',
                  icon: Icons.date_range_rounded,
                  isSelected: _isSearchAllPeriod,
                  activeColor: AppColors.primary,
                  onTap: () {
                    setState(() => _searchAllPeriod = !_isSearchAllPeriod);
                  },
                ),
              ],

              // Reset All Filters Button
              if (isFiltering) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: _resetAllFilters,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD4DF)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.refresh_rounded, size: 14, color: Color(0xFFBD382B)),
                        SizedBox(width: 4),
                        Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFBD382B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. Section Header: Title & Result Count Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isFiltering ? 'Hasil Pencarian' : 'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            if (isFiltering)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.mintAccentBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$resultCount transaksi',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    VoidCallback? onTap,
    Color? activeColor,
    Widget? trailing,
  }) {
    final effectiveColor = activeColor ?? AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
          decoration: BoxDecoration(
            color: isSelected
                ? effectiveColor.withValues(alpha: 0.14)
                : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? effectiveColor : AppColors.borderSubtle,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? effectiveColor : AppColors.textMuted,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? effectiveColor : AppColors.onSurface,
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCC8BB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Kategori',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (_selectedCategoryId != null)
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedCategoryId = null);
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Reset Filter',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF757575)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Category List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // All Categories Option
                    _buildCategoryOptionTile(
                      ctx: ctx,
                      title: 'Semua Kategori',
                      icon: Icons.grid_view_rounded,
                      color: AppColors.primary,
                      isSelected: _selectedCategoryId == null,
                      onTap: () {
                        setState(() => _selectedCategoryId = null);
                        Navigator.pop(ctx);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Section: Pengeluaran
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'KATEGORI PENGELUARAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    ...DefaultCategories.expenseCategories.map((cat) {
                      return _buildCategoryOptionTile(
                        ctx: ctx,
                        title: cat.name,
                        icon: cat.icon,
                        color: cat.color,
                        isSelected: _selectedCategoryId == cat.id,
                        onTap: () {
                          setState(() => _selectedCategoryId = cat.id);
                          Navigator.pop(ctx);
                        },
                      );
                    }),
                    const SizedBox(height: 14),

                    // Section: Pemasukan
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'KATEGORI PEMASUKAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    ...DefaultCategories.incomeCategories.map((cat) {
                      return _buildCategoryOptionTile(
                        ctx: ctx,
                        title: cat.name,
                        icon: cat.icon,
                        color: cat.color,
                        isSelected: _selectedCategoryId == cat.id,
                        onTap: () {
                          setState(() => _selectedCategoryId = cat.id);
                          Navigator.pop(ctx);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryOptionTile({
    required BuildContext ctx,
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.12) : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? color : AppColors.borderSubtle,
          width: isSelected ? 1.4 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, size: 20, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetAllFilters() {
    setState(() {
      _effectiveSearchController.clear();
      _selectedTypeFilter = null;
      _selectedCategoryId = null;
      _searchAllPeriod = false;
    });
  }

  /// Membuka modal pemilih bulan & tahun atau kalender tanggal spesifik
  void _showDateFilterModal() {
    final curDate = selectedDate;
    final daySpecific = isDaySpecific;
    int pickerYear = curDate.year;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final months = [
              {'name': 'Jan', 'val': 1},
              {'name': 'Feb', 'val': 2},
              {'name': 'Mar', 'val': 3},
              {'name': 'Apr', 'val': 4},
              {'name': 'May', 'val': 5},
              {'name': 'Jun', 'val': 6},
              {'name': 'Jul', 'val': 7},
              {'name': 'Aug', 'val': 8},
              {'name': 'Sep', 'val': 9},
              {'name': 'Oct', 'val': 10},
              {'name': 'Nov', 'val': 11},
              {'name': 'Dec', 'val': 12},
            ];

            final currentNow = DateTime.now();

            return Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: 42,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCC8BB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Row: Title & Quick Reset Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Periode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          backgroundColor: const Color(0xFFE8F7F0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime.now();
                            _isDaySpecific = false;
                          });
                          Navigator.pop(bottomSheetContext);
                        },
                        icon: const Icon(Icons.today_rounded, size: 16),
                        label: const Text(
                          'Bulan Ini',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Year Navigation Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF2EB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2CFC2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left_rounded, color: AppColors.onSurface),
                          onPressed: () {
                            setModalState(() {
                              pickerYear--;
                            });
                          },
                        ),
                        Text(
                          '$pickerYear',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right_rounded, color: AppColors.onSurface),
                          onPressed: () {
                            setModalState(() {
                              pickerYear++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Grid of 12 Months (4 columns x 3 rows)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.45,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final m = months[index];
                      final int monthVal = m['val'] as int;
                      final bool isSelected = !daySpecific &&
                          curDate.year == pickerYear &&
                          curDate.month == monthVal;
                      final bool isCurrentMonth =
                          currentNow.year == pickerYear && currentNow.month == monthVal;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDate = DateTime(pickerYear, monthVal, 1);
                              _isDaySpecific = false;
                            });
                            Navigator.pop(bottomSheetContext);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : isCurrentMonth
                                      ? const Color(0xFFE8F7F0)
                                      : const Color(0xFFFAF2EB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : isCurrentMonth
                                        ? const Color(0xFF9BDBC1)
                                        : const Color(0xFFE2CFC2),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  m['name'] as String,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isSelected || isCurrentMonth
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : isCurrentMonth
                                            ? AppColors.primary
                                            : AppColors.onSurface,
                                  ),
                                ),
                                if (isCurrentMonth && !isSelected)
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Option to pick a specific Date / Day via Calendar Picker
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurface,
                      side: const BorderSide(color: Color(0xFFE2CFC2), width: 1.2),
                      backgroundColor: const Color(0xFFFAF2EB),
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(bottomSheetContext);
                      final picked = await showDatePicker(
                        context: this.context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                        builder: (pickerCtx, child) {
                          return Theme(
                            data: Theme.of(pickerCtx).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                surface: AppColors.background,
                                onSurface: AppColors.onSurface,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _isDaySpecific = true;
                        });
                      }
                    },
                    icon: Icon(Icons.event_note_rounded, size: 18, color: AppColors.primary),
                    label: const Text(
                      'Pilih Tanggal Tertentu (Spesifik Hari)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonthlySummaryCard({
    required String expenses,
    required String income,
    required String balance,
  }) {
    final curDate = selectedDate;
    final daySpecific = isDaySpecific;
    final yearStr = DateFormat('yyyy').format(curDate);
    final monthStr = daySpecific
        ? DateFormat('d MMM').format(curDate)
        : DateFormat('MMM').format(curDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceAlt,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Month Selector Pill (Clickable)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showDateFilterModal,
              borderRadius: BorderRadius.circular(16),
              splashColor: AppColors.primary.withValues(alpha: 0.12),
              highlightColor: AppColors.primary.withValues(alpha: 0.08),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: daySpecific ? const Color(0xFFE8F7F0) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: daySpecific ? AppColors.primary : const Color(0xFFE2CFC2),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      yearStr,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: daySpecific ? AppColors.primary : const Color(0xFF757575),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          monthStr,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: daySpecific ? AppColors.primary : AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 15,
                          color: daySpecific ? AppColors.primary : AppColors.onSurface,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Expenses
          Expanded(
            child: _buildSummaryColumn(
              label: 'Expenses',
              value: expenses,
              valueColor: AppColors.expense,
            ),
          ),
          _buildVerticalDivider(),

          // Income
          Expanded(
            child: _buildSummaryColumn(
              label: 'Income',
              value: income,
              valueColor: AppColors.income,
            ),
          ),
          _buildVerticalDivider(),

          // Balance
          Expanded(
            child: _buildSummaryColumn(
              label: 'Balance',
              value: balance,
              valueColor: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 26,
      width: 1,
      color: AppColors.divider,
    );
  }

  Widget _buildDateSection({
    required String dateTitle,
    required String expensesText,
    String? incomeText,
    required List<TransactionModel> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateTitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                ),
              ),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Expenses: ',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF757575),
                          ),
                        ),
                        TextSpan(
                          text: expensesText,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (incomeText != null) ...[
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Income: ',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF757575),
                            ),
                          ),
                          TextSpan(
                            text: incomeText,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),

        // Group Card Container
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.borderSubtle,
              width: 1.2,
            ),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final bool isLast = index == items.length - 1;
              return Column(
                children: [
                  _buildTransactionTile(item),
                  if (!isLast)
                    Divider(
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
        ),
      ],
    );
  }

  Widget _buildTransactionTile(TransactionModel tx) {
    final cat = DefaultCategories.byId(tx.categoryId);
    final icon = cat?.icon ?? Icons.category_rounded;
    final iconColor = cat?.color ?? const Color(0xFF8E4C3B);
    final iconBgColor = (cat != null)
        ? cat.color.withValues(alpha: 0.18)
        : const Color(0xFFFFDED4);
    final bool isExpense = tx.type == TransactionType.expense;

    final formattedAmt = (isExpense ? '-' : '+') + AppFormatters.formatCurrency(tx.amount);

    return Dismissible(
      key: ValueKey(tx.id ?? tx.date.millisecondsSinceEpoch),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD4DF),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFBD382B)),
      ),
      onDismissed: (_) async {
        if (tx.id != null) {
          await DbHelper.instance.deleteTransaction(tx.id!);
          loadData();
          NotificationService.instance.refreshUnreadCount();
        }
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTransactionDetailModal(tx),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
            child: Row(
              children: [
                // Circle Icon Badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),

                // Title / Note
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title.isNotEmpty ? tx.title : (cat?.name ?? 'Transaction'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (tx.note != null && tx.note!.isNotEmpty && tx.note != tx.title)
                        Text(
                          tx.note!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8E9A92),
                          ),
                        ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  formattedAmt,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isExpense ? AppColors.expense : AppColors.income,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetailModal(TransactionModel tx) {
    final cat = DefaultCategories.byId(tx.categoryId);
    final icon = cat?.icon ?? Icons.category_rounded;
    final iconColor = cat?.color ?? const Color(0xFF8E4C3B);
    final iconBgColor = (cat != null)
        ? cat.color.withValues(alpha: 0.18)
        : const Color(0xFFFFDED4);
    final bool isExpense = tx.type == TransactionType.expense;
    final formattedAmt = (isExpense ? '-' : '+') + AppFormatters.formatCurrency(tx.amount);
    final dateFormatted = DateFormat('EEEE, d MMMM yyyy • HH:mm').format(tx.date);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCC8BB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),

              // Icon & Title & Type
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title.isNotEmpty ? tx.title : (cat?.name ?? 'Transaksi'),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cat?.name ?? 'Umum',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpense ? const Color(0xFFFFECE5) : const Color(0xFFE8F7F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isExpense ? 'Pengeluaran' : 'Pemasukan',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isExpense ? AppColors.expense : AppColors.income,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nominal Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL NOMINAL',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedAmt,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: isExpense ? AppColors.expense : AppColors.income,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          dateFormatted,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (tx.note != null && tx.note!.isNotEmpty && tx.note != tx.title) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notes_rounded, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tx.note!,
                          style: TextStyle(fontSize: 12.5, color: AppColors.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Action Buttons: Edit & Delete
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.pop(bottomSheetContext);
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTransactionScreen(initialTransaction: tx),
                          ),
                        );
                        if (result == true) {
                          loadData();
                          NotificationService.instance.refreshUnreadCount();
                        }
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text(
                        'Edit Transaksi',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFFECE5),
                      foregroundColor: const Color(0xFFBD382B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(13),
                    ),
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _confirmDeleteTransaction(tx);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    tooltip: 'Hapus Transaksi',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteTransaction(TransactionModel tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Transaksi?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan transaksi "${tx.title}" sebesar ${AppFormatters.formatCurrency(tx.amount)}?',
          style: const TextStyle(fontSize: 13),
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
              Navigator.pop(ctx);
              if (tx.id != null) {
                await DbHelper.instance.deleteTransaction(tx.id!);
                loadData();
                NotificationService.instance.refreshUnreadCount();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaksi berhasil dihapus'),
                      backgroundColor: Color(0xFFBD382B),
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
