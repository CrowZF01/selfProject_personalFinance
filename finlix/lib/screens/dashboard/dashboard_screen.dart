import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/data/default_categories.dart';
import '../../core/database/db_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../models/transaction_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await DbHelper.instance.getAllTransactions();
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

  // Format currency
  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.##', 'en_US');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    double totalIncome = 0;
    double totalExpense = 0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }
    final double balance = totalIncome - totalExpense;

    // Group transactions by Date String (e.g. '16 Sept Wednesday')
    final Map<String, List<TransactionModel>> grouped = {};
    for (var tx in _transactions) {
      final dateKey = DateFormat('d MMM EEEE').format(tx.date);
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
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.onSurface, size: 26),
          onPressed: () {},
        ),
        title: const Text(
          'Money Tracker',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.onSurface, size: 24),
            onPressed: loadData,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 4.0),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFFEBD8CB),
              child: const CircleAvatar(
                radius: 15,
                backgroundColor: Color(0xFFFFDED4),
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
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
                      // Monthly Summary Card
                      _buildMonthlySummaryCard(
                        expenses: _formatAmount(totalExpense),
                        income: _formatAmount(totalIncome),
                        balance: _formatAmount(balance),
                      ),
                      const SizedBox(height: 18),

                      if (_transactions.isEmpty)
                        _buildEmptyState()
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
                              expensesText: groupExpense > 0 ? _formatAmount(groupExpense) : '0',
                              incomeText: groupIncome > 0 ? _formatAmount(groupIncome) : null,
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF1E8),
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
            decoration: const BoxDecoration(
              color: Color(0xFFFFDED4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 38,
              color: Color(0xFF8E4C3B),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tekan tombol + di bawah untuk mencatat pengeluaran atau pemasukan baru Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF757575),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryCard({
    required String expenses,
    required String income,
    required String balance,
  }) {
    final now = DateTime.now();
    final yearStr = DateFormat('yyyy').format(now);
    final monthStr = DateFormat('MMM').format(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2EB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Month Selector Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2CFC2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  yearStr,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      monthStr,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: AppColors.onSurface,
                    ),
                  ],
                ),
              ],
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
      color: const Color(0xFFEADBCE),
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
                          style: const TextStyle(
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
                            style: const TextStyle(
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
            color: const Color(0xFFFAF1E8),
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
        ),
      ],
    );
  }

  Widget _buildTransactionTile(TransactionModel tx) {
    final cat = DefaultCategories.byId(tx.categoryId);
    final icon = cat?.icon ?? Icons.category_rounded;
    final iconColor = cat?.color ?? const Color(0xFF8E4C3B);
    final iconBgColor = (cat != null)
        ? cat.color.withOpacity(0.18)
        : const Color(0xFFFFDED4);
    final bool isExpense = tx.type == TransactionType.expense;

    final formattedAmt = (isExpense ? '-' : '') + _formatAmount(tx.amount);

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
        }
      },
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
                    style: const TextStyle(
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
    );
  }
}
