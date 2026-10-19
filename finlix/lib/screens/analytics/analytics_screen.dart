import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/data/default_categories.dart';
import '../../core/database/db_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => AnalyticsScreenState();
}

class AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime? _selectedMonth;
  DateTime get selectedMonth => _selectedMonth ?? DateTime.now();

  List<TransactionModel> _allTransactions = [];
  bool _isLoading = true;
  double? _monthlyBudget;
  double get monthlyBudget => _monthlyBudget ?? 1500.0;

  int _selectedChartTab = 0; // 0 = Donut Chart, 1 = Weekly Bar Chart
  int _touchedPieIndex = -1;
  int _touchedBarIndex = -1;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    loadData();
  }

  /// Memuat semua transaksi dan batas budget dari SQLite
  Future<void> loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await DbHelper.instance.getAllTransactions();
      final budget = await DbHelper.instance.getMonthlyBudget();
      if (mounted) {
        setState(() {
          _allTransactions = data;
          _monthlyBudget = budget;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEditBudgetModal() {
    final controller = TextEditingController(text: monthlyBudget.toStringAsFixed(0));
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
                    'Tetapkan target maksimal belanja bulanan untuk menjaga stabilitas dompet FinLix Anda.',
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
                            : [500.0, 1000.0, 1500.0, 2000.0, 3000.0])
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
                      prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.primary),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                                content: Text('Batas budget bulanan berhasil diubah ke ${AppFormatters.formatCurrency(parsed)}!'),
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

  /// Pindah ke bulan sebelumnya
  void _prevMonth() {
    final cur = selectedMonth;
    setState(() {
      _selectedMonth = DateTime(cur.year, cur.month - 1);
      _touchedPieIndex = -1;
      _touchedBarIndex = -1;
    });
  }

  /// Pindah ke bulan berikutnya
  void _nextMonth() {
    final cur = selectedMonth;
    setState(() {
      _selectedMonth = DateTime(cur.year, cur.month + 1);
      _touchedPieIndex = -1;
      _touchedBarIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final curMonth = selectedMonth;

    // Filter transaksi berdasarkan bulan & tahun yang dipilih
    final monthlyTransactions = _allTransactions.where((tx) {
      return tx.date.year == curMonth.year && tx.date.month == curMonth.month;
    }).toList();

    // Hitung total pengeluaran & pemasukan bulan ini
    double totalExpense = 0;
    double totalIncome = 0;
    final List<TransactionModel> expenseTransactions = [];

    for (var tx in monthlyTransactions) {
      if (tx.type == TransactionType.expense) {
        totalExpense += tx.amount;
        expenseTransactions.add(tx);
      } else {
        totalIncome += tx.amount;
      }
    }

    final hasExpenses = totalExpense > 0;

    // Hitung pengeluaran per kategori
    final Map<String, double> categoryTotals = {};
    final Map<String, int> categoryCounts = {};
    for (var tx in expenseTransactions) {
      categoryTotals[tx.categoryId] = (categoryTotals[tx.categoryId] ?? 0) + tx.amount;
      categoryCounts[tx.categoryId] = (categoryCounts[tx.categoryId] ?? 0) + 1;
    }

    // Urutkan kategori berdasarkan total pengeluaran terbesar
    final sortedCategoryEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
                  'Analytics',
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
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Month Selector Card
                      _buildMonthSelectorCard(),
                      const SizedBox(height: 14),

                      // Total Spent Summary Card dengan Segmented Category Progress Bar
                      _buildTotalSpentCard(
                        totalExpense: totalExpense,
                        totalIncome: totalIncome,
                        sortedCategories: sortedCategoryEntries,
                      ),
                      const SizedBox(height: 18),

                      if (!hasExpenses)
                        _buildEmptyExpenseState()
                      else ...[
                        // Step 2.3: Visualisasi Donut/Pie Chart & Weekly Bar Chart (fl_chart)
                        _buildChartCard(
                          totalExpense: totalExpense,
                          sortedCategories: sortedCategoryEntries,
                          expenseTransactions: expenseTransactions,
                        ),
                        const SizedBox(height: 18),

                        // Category Breakdown Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Category Breakdown',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F7F0),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '${sortedCategoryEntries.length} ${sortedCategoryEntries.length == 1 ? "Category" : "Categories"}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF006C49),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Daftar Kartu Kategori Riil dari Database
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sortedCategoryEntries.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final entry = sortedCategoryEntries[index];
                            final cat = DefaultCategories.byId(entry.key);
                            final spent = entry.value;
                            final count = categoryCounts[entry.key] ?? 1;
                            final percentage = totalExpense > 0 ? (spent / totalExpense) * 100 : 0.0;

                            final icon = cat?.icon ?? Icons.category_rounded;
                            final color = cat?.color ?? AppColors.primary;
                            final name = cat?.name ?? 'Other';

                            return _buildCategoryCard(
                              icon: icon,
                              iconBgColor: color.withValues(alpha: 0.16),
                              iconColor: color,
                              title: name,
                              subtitle: '$count ${count == 1 ? "transaction" : "transactions"} • ${percentage.toStringAsFixed(1)}%',
                              spent: AppFormatters.formatCurrency(spent),
                              total: AppFormatters.formatCurrency(totalExpense),
                              progress: totalExpense > 0 ? (spent / totalExpense) : 0.0,
                              progressColor: color,
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Dynamic Smart Insight Card
                        _buildSmartInsightCard(
                          totalExpense: totalExpense,
                          totalIncome: totalIncome,
                          topCategoryEntry: sortedCategoryEntries.isNotEmpty ? sortedCategoryEntries.first : null,
                        ),
                      ],

                      // Space for bottom nav bar
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Kartu Visualisasi Grafik Interaktif (Donut Share & Weekly Bar Chart)
  Widget _buildChartCard({
    required double totalExpense,
    required List<MapEntry<String, double>> sortedCategories,
    required List<TransactionModel> expenseTransactions,
  }) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Judul & Switch Tab Grafik
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SPENDING BREAKDOWN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Color(0xFF6E7A72),
                ),
              ),
              // Segmented Toggle Pill (Donut / Bar)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E4DA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildChartToggleTab(
                      index: 0,
                      icon: Icons.donut_large_rounded,
                      label: 'Donut',
                    ),
                    const SizedBox(width: 3),
                    _buildChartToggleTab(
                      index: 1,
                      icon: Icons.bar_chart_rounded,
                      label: 'Weekly',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tampilan Grafik Sesuai Tab Terpilih
          if (_selectedChartTab == 0)
            _buildDonutChartSection(
              totalExpense: totalExpense,
              sortedCategories: sortedCategories,
            )
          else
            _buildWeeklyBarChartSection(
              expenseTransactions: expenseTransactions,
              totalExpense: totalExpense,
            ),
        ],
      ),
    );
  }

  Widget _buildChartToggleTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _selectedChartTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedChartTab = index;
          _touchedPieIndex = -1;
          _touchedBarIndex = -1;
        });
      },
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF6E7A72),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF6E7A72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChartSection({
    required double totalExpense,
    required List<MapEntry<String, double>> sortedCategories,
  }) {
    MapEntry<String, double>? activeEntry;
    if (_touchedPieIndex >= 0 && _touchedPieIndex < sortedCategories.length) {
      activeEntry = sortedCategories[_touchedPieIndex];
    }

    final activeCat = activeEntry != null ? DefaultCategories.byId(activeEntry.key) : null;
    final activeSpent = activeEntry?.value ?? totalExpense;
    final activePercentage = totalExpense > 0 ? (activeSpent / totalExpense) * 100 : 0.0;
    final activeTitle = activeCat?.name ?? 'Total Spent';

    return Column(
      children: [
        SizedBox(
          height: 205,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedPieIndex = -1;
                          return;
                        }
                        _touchedPieIndex =
                            pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 52,
                  sections: sortedCategories.asMap().entries.map((item) {
                    final index = item.key;
                    final entry = item.value;
                    final cat = DefaultCategories.byId(entry.key);
                    final color = cat?.color ?? AppColors.primary;
                    final double spent = entry.value;
                    final double percent = totalExpense > 0 ? (spent / totalExpense) * 100 : 0;
                    final isTouched = index == _touchedPieIndex;
                    final radius = isTouched ? 36.0 : 28.0;

                    return PieChartSectionData(
                      color: color,
                      value: spent,
                      title: '${percent.toStringAsFixed(0)}%',
                      radius: radius,
                      showTitle: percent >= 8,
                      titleStyle: TextStyle(
                        fontSize: isTouched ? 12.5 : 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Konten Tengah Lubang Donut (Nama Kategori & Nominal)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activeCat != null ? activeTitle : 'Total Spent',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: activeCat?.color ?? const Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.formatCurrency(activeSpent),
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (activeCat != null)
                    Text(
                      '${activePercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: activeCat.color,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Interactive Legend Wrap
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: sortedCategories.asMap().entries.map((item) {
            final index = item.key;
            final entry = item.value;
            final cat = DefaultCategories.byId(entry.key);
            final color = cat?.color ?? AppColors.primary;
            final name = cat?.name ?? 'Other';
            final percent = totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0.0;
            final isSelected = index == _touchedPieIndex;

            return InkWell(
              onTap: () {
                setState(() {
                  _touchedPieIndex = isSelected ? -1 : index;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFFE2CFC2),
                    width: isSelected ? 1.4 : 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$name ${percent.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.onSurface : const Color(0xFF6E7A72),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWeeklyBarChartSection({
    required List<TransactionModel> expenseTransactions,
    required double totalExpense,
  }) {
    // Kelompokkan pengeluaran ke 5 rentang mingguan dalam sebulan
    final weeklyTotals = [0.0, 0.0, 0.0, 0.0, 0.0];
    for (var tx in expenseTransactions) {
      final day = tx.date.day;
      if (day <= 7) {
        weeklyTotals[0] += tx.amount;
      } else if (day <= 14) {
        weeklyTotals[1] += tx.amount;
      } else if (day <= 21) {
        weeklyTotals[2] += tx.amount;
      } else if (day <= 28) {
        weeklyTotals[3] += tx.amount;
      } else {
        weeklyTotals[4] += tx.amount;
      }
    }

    double maxVal = 0;
    int peakWeekIndex = 0;
    for (int i = 0; i < weeklyTotals.length; i++) {
      if (weeklyTotals[i] > maxVal) {
        maxVal = weeklyTotals[i];
        peakWeekIndex = i;
      }
    }
    final maxY = maxVal > 0 ? maxVal * 1.25 : 100.0;
    final weeklyAvg = weeklyTotals.reduce((a, b) => a + b) / 5;

    final weekLabels = ['W1\n1-7', 'W2\n8-14', 'W3\n15-21', 'W4\n22-28', 'W5\n29+'];

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        barTouchResponse == null ||
                        barTouchResponse.spot == null) {
                      _touchedBarIndex = -1;
                      return;
                    }
                    _touchedBarIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                  });
                },
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => const Color(0xFF2C3E35),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final weekNum = group.x + 1;
                    return BarTooltipItem(
                      'Week $weekNum\n${AppFormatters.formatCurrency(rod.toY)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= weekLabels.length) {
                        return const SizedBox();
                      }
                      final isSelected = index == _touchedBarIndex || index == peakWeekIndex;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          weekLabels[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : const Color(0xFF757575),
                            height: 1.15,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 3,
                getDrawingHorizontalLine: (value) => const FlLine(
                  color: Color(0xFFEBDDD3),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              barGroups: weeklyTotals.asMap().entries.map((item) {
                final index = item.key;
                final val = item.value;
                final isPeak = index == peakWeekIndex && val > 0;
                final isTouched = index == _touchedBarIndex;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: val,
                      color: isTouched
                          ? const Color(0xFF00583A)
                          : isPeak
                              ? AppColors.primary
                              : const Color(0xFF81B29A),
                      width: 22,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY,
                        color: const Color(0xFFF3E7DC),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Bottom Stats Summary Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    maxVal > 0
                        ? 'Peak: Week ${peakWeekIndex + 1} (${AppFormatters.formatCurrency(maxVal)})'
                        : 'No expenses yet',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Weekly Avg: ${AppFormatters.formatCurrency(weeklyAvg)}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6E7A72),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthSelectorCard() {
    final cur = selectedMonth;
    final monthLabel = DateFormat('MMMM yyyy').format(cur);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2EB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Chevron Button
          InkWell(
            onTap: _prevMonth,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE2CFC2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.onSurface,
                size: 20,
              ),
            ),
          ),

          // Center Date (Clickable to open month picker modal)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showMonthPickerModal,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF006C49),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      monthLabel,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppColors.onSurface,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Chevron Button
          InkWell(
            onTap: _nextMonth,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE2CFC2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.onSurface,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Modal Pemilih Bulan & Tahun langsung di Analytics Screen
  void _showMonthPickerModal() {
    int pickerYear = selectedMonth.year;

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
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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

                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Bulan Analitik',
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
                            _selectedMonth = DateTime.now();
                            _touchedPieIndex = -1;
                            _touchedBarIndex = -1;
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
                          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.onSurface),
                          onPressed: () {
                            setModalState(() {
                              pickerYear--;
                            });
                          },
                        ),
                        Text(
                          '$pickerYear',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: AppColors.onSurface),
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
                      final bool isSelected = selectedMonth.year == pickerYear &&
                          selectedMonth.month == monthVal;
                      final bool isCurrentMonth =
                          currentNow.year == pickerYear && currentNow.month == monthVal;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedMonth = DateTime(pickerYear, monthVal, 1);
                              _touchedPieIndex = -1;
                              _touchedBarIndex = -1;
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
                                    decoration: const BoxDecoration(
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTotalSpentCard({
    required double totalExpense,
    required double totalIncome,
    required List<MapEntry<String, double>> sortedCategories,
  }) {
    final double budget = monthlyBudget;
    final double remainingBudget = budget - totalExpense;
    final bool isOverBudget = budget > 0 && totalExpense > budget;
    final bool isNearLimit = !isOverBudget && budget > 0 && totalExpense >= (budget * 0.8);
    final double budgetPercent = budget > 0 ? ((totalExpense / budget) * 100) : 0.0;

    final Color statusBg = isOverBudget
        ? const Color(0xFFFFECE5)
        : (isNearLimit ? const Color(0xFFFEF3C7) : const Color(0xFFD4EFE1));
    final Color statusTextColor = isOverBudget
        ? const Color(0xFFBD382B)
        : (isNearLimit ? const Color(0xFFB45309) : const Color(0xFF006C49));
    final String statusLabel = isOverBudget
        ? 'Over Budget'
        : (isNearLimit ? 'Mendekati Batas (80%+)' : 'On Track');
    final IconData statusIcon = isOverBudget
        ? Icons.warning_amber_rounded
        : (isNearLimit ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Total Spent label + Status badge + Edit Budget button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL SPENT THIS MONTH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Color(0xFF6E7A72),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 13,
                          color: statusTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: statusTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: _showEditBudgetModal,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFF3D5C8),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: Color(0xFF8E4C3B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Main Amount Display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                AppFormatters.formatCurrency(totalExpense),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${AppFormatters.formatCurrency(budget)} budget',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6E7A72),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Budget Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: budget > 0 ? (totalExpense / budget).clamp(0.0, 1.0) : 0.0,
              minHeight: 8,
              backgroundColor: const Color(0xFFF0E4DA),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget
                    ? const Color(0xFFBD382B)
                    : (isNearLimit ? const Color(0xFFE28A3B) : const Color(0xFF006C49)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Dynamic Segmented Category Bar
          if (sortedCategories.isNotEmpty && totalExpense > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 6,
                color: const Color(0xFFF0E4DA),
                child: Row(
                  children: sortedCategories.map((entry) {
                    final cat = DefaultCategories.byId(entry.key);
                    final color = cat?.color ?? AppColors.primary;
                    final flex = ((entry.value / totalExpense) * 1000).toInt().clamp(1, 1000);
                    return Expanded(
                      flex: flex,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        color: color,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Bottom Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${budgetPercent.toStringAsFixed(1)}% anggaran terpakai',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6E7A72),
                ),
              ),
              Text(
                remainingBudget >= 0
                    ? '+${AppFormatters.formatCurrency(remainingBudget)} sisa budget'
                    : '-${AppFormatters.formatCurrency(remainingBudget.abs())} over budget',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: remainingBudget >= 0 ? const Color(0xFF006C49) : const Color(0xFFBD382B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyExpenseState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2EB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7F0),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCBEBD8), width: 1.5),
            ),
            child: const Icon(
              Icons.query_stats_rounded,
              color: Color(0xFF006C49),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Expenses This Month',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Transactions you add with the (+) button will automatically appear here to visualize your spending trends.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF757575),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String spent,
    required String total,
    required double progress,
    required Color progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF1E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Category Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),

              // Spent / Total
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    spent,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    ' / $total',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: const Color(0xFFEDE0D4),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsightCard({
    required double totalExpense,
    required double totalIncome,
    required MapEntry<String, double>? topCategoryEntry,
  }) {
    String insightTitle = 'Smart Insight';
    String badgeText = 'Positive';
    Color badgeColor = const Color(0xFF006C49);
    Color badgeBg = const Color(0xFFD4EFE1);
    String insightMessage = '';

    if (topCategoryEntry != null) {
      final cat = DefaultCategories.byId(topCategoryEntry.key);
      final catName = cat?.name ?? 'Other';
      final double percentage = totalExpense > 0 ? (topCategoryEntry.value / totalExpense) * 100 : 0;

      badgeText = 'Top Category';
      badgeColor = const Color(0xFFD97706);
      badgeBg = const Color(0xFFFFEDD5);

      insightMessage =
          '$catName is your largest expense this month, accounting for ${AppFormatters.formatCurrency(topCategoryEntry.value)} (${percentage.toStringAsFixed(0)}% of total spent).';
    } else {
      insightMessage = 'You have no expenses recorded for this month yet.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF1E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lightbulb Icon Container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFED7AA),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFF59E0B),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      insightTitle,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  insightMessage,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF6E7A72),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
