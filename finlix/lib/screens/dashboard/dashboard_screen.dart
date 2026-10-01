import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: AppColors.onSurface, size: 24),
            onPressed: () {},
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Summary Card
              _buildMonthlySummaryCard(),
              const SizedBox(height: 18),

              // Group 1: 16 Sept Wednesday
              _buildDateSection(
                dateTitle: '16 Sept Wednesday',
                expensesText: '66,000',
                incomeText: null,
                items: [
                  _TransactionItemData(
                    title: 'Beli Roti for BW',
                    amount: '-66,000',
                    isExpense: true,
                    icon: Icons.bakery_dining_rounded,
                    iconBgColor: AppColors.pastelPeach,
                    iconColor: AppColors.iconPeach,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Group 2: 13 Sept Sunday
              _buildDateSection(
                dateTitle: '13 Sept Sunday',
                expensesText: '30,000',
                incomeText: '22,000',
                items: [
                  _TransactionItemData(
                    title: 'gemini',
                    amount: '-15,000',
                    isExpense: true,
                    icon: Icons.school_outlined,
                    iconBgColor: AppColors.pastelOrange,
                    iconColor: AppColors.iconPeach,
                  ),
                  _TransactionItemData(
                    title: 'free',
                    amount: '22,000',
                    isExpense: false,
                    icon: Icons.savings_outlined,
                    iconBgColor: AppColors.pastelPurple,
                    iconColor: AppColors.iconPurple,
                  ),
                  _TransactionItemData(
                    title: 'Matcha Latte USDA',
                    amount: '-15,000',
                    isExpense: true,
                    icon: Icons.coffee_outlined,
                    iconBgColor: AppColors.pastelMint,
                    iconColor: AppColors.iconMint,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Group 3: 8 Sept Tuesday
              _buildDateSection(
                dateTitle: '8 Sept Tuesday',
                expensesText: '38,500',
                incomeText: null,
                items: [
                  _TransactionItemData(
                    title: 'Dawet',
                    amount: '-6,000',
                    isExpense: true,
                    icon: Icons.restaurant_rounded,
                    iconBgColor: AppColors.pastelMint,
                    iconColor: AppColors.iconMint,
                  ),
                  _TransactionItemData(
                    title: 'Bensin',
                    amount: '-15,000',
                    isExpense: true,
                    icon: Icons.local_gas_station_rounded,
                    iconBgColor: AppColors.pastelPeach,
                    iconColor: AppColors.iconPeach,
                  ),
                  _TransactionItemData(
                    title: 'Basreng USDA',
                    amount: '-17,500',
                    isExpense: true,
                    icon: Icons.lunch_dining_rounded,
                    iconBgColor: AppColors.pastelMint,
                    iconColor: AppColors.iconMint,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Group 4: 4 Sept Friday
              _buildDateSection(
                dateTitle: '4 Sept Friday',
                expensesText: '320,000',
                incomeText: '940,000',
                items: [
                  _TransactionItemData(
                    title: 'Kuota',
                    amount: '-150,000',
                    isExpense: true,
                    icon: Icons.phone_android_rounded,
                    iconBgColor: AppColors.pastelPeach,
                    iconColor: AppColors.iconPeach,
                  ),
                  _TransactionItemData(
                    title: 'Anker Charger',
                    amount: '-170,000',
                    isExpense: true,
                    icon: Icons.shopping_cart_outlined,
                    iconBgColor: AppColors.pastelPurple,
                    iconColor: AppColors.iconPurple,
                  ),
                  _TransactionItemData(
                    title: 'Asdos',
                    amount: '440,000',
                    isExpense: false,
                    icon: Icons.payments_outlined,
                    iconBgColor: AppColors.pastelMint,
                    iconColor: AppColors.iconMint,
                  ),
                ],
              ),

              // Bottom padding to avoid overlapping floating nav bar
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlySummaryCard() {
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
                const Text(
                  '2026',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Sept',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
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
              value: '454,500',
              valueColor: AppColors.expense,
            ),
          ),
          _buildVerticalDivider(),

          // Income
          Expanded(
            child: _buildSummaryColumn(
              label: 'Income',
              value: '962,000',
              valueColor: AppColors.income,
            ),
          ),
          _buildVerticalDivider(),

          // Balance
          Expanded(
            child: _buildSummaryColumn(
              label: 'Balance',
              value: '507,500',
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
    required List<_TransactionItemData> items,
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

  Widget _buildTransactionTile(_TransactionItemData item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
      child: Row(
        children: [
          // Circle Icon Badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Title
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),

          // Amount
          Text(
            item.amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: item.isExpense ? AppColors.expense : AppColors.income,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItemData {
  final String title;
  final String amount;
  final bool isExpense;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  _TransactionItemData({
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}
