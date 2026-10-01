import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Month Selector Card
              _buildMonthSelectorCard(),
              const SizedBox(height: 14),

              // Total Spent / Budget Summary Card
              _buildTotalSpentCard(),
              const SizedBox(height: 18),

              // Category Budgets Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category Budgets',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4EFE1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Manage',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF006C49),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category Budget Cards
              _buildCategoryCard(
                icon: Icons.bakery_dining_rounded,
                iconBgColor: const Color(0xFFFFE5D9),
                iconColor: const Color(0xFFD97706),
                title: 'Food & Dining',
                subtitle: 'Restaurants & takeout',
                spent: r'$450',
                total: r'$600',
                progress: 450 / 600,
                progressColor: const Color(0xFFEA580C),
              ),
              const SizedBox(height: 10),

              _buildCategoryCard(
                icon: Icons.eco_rounded,
                iconBgColor: const Color(0xFFD4EFE1),
                iconColor: const Color(0xFF006C49),
                title: 'Groceries',
                subtitle: 'Supermarkets & fresh produce',
                spent: r'$284',
                total: r'$500',
                progress: 284 / 500,
                progressColor: const Color(0xFF059669),
              ),
              const SizedBox(height: 10),

              _buildCategoryCard(
                icon: Icons.electric_moped_rounded,
                iconBgColor: const Color(0xFFE4E0FF),
                iconColor: const Color(0xFF6366F1),
                title: 'Transport',
                subtitle: 'Metro, rides & fuel',
                spent: r'$95',
                total: r'$200',
                progress: 95 / 200,
                progressColor: const Color(0xFF6366F1),
              ),
              const SizedBox(height: 10),

              _buildCategoryCard(
                icon: Icons.shopping_bag_outlined,
                iconBgColor: const Color(0xFFFFD4DF),
                iconColor: const Color(0xFFE11D48),
                title: 'Shopping & Retail',
                subtitle: 'Clothing & essentials',
                spent: r'$210',
                total: r'$350',
                progress: 210 / 350,
                progressColor: const Color(0xFFE11D48),
              ),
              const SizedBox(height: 14),

              // Smart Insight Card
              _buildSmartInsightCard(),

              // Space for bottom nav bar
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelectorCard() {
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
          Container(
            width: 32,
            height: 32,
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

          // Center Date
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF006C49),
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'October 2024',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),

          // Right Chevron Button
          Container(
            width: 32,
            height: 32,
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
        ],
      ),
    );
  }

  Widget _buildTotalSpentCard() {
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
          // Top Row: Total Spent label + On Track badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL SPENT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Color(0xFF6E7A72),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4EFE1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                      color: Color(0xFF006C49),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'On Track',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF006C49),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Main Amount Display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                r'$1,420.50',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(width: 6),
              Text(
                r'/ $2,500',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6E7A72),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Segmented Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 10,
              color: const Color(0xFFF0E4DA),
              child: Row(
                children: [
                  Expanded(
                    flex: 30,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 20,
                    child: Container(color: const Color(0xFF6EE7B7)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 18,
                    child: Container(color: const Color(0xFF93C5FD)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 14,
                    child: Container(color: const Color(0xFFFCA5A5)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 18,
                    child: Container(color: Colors.transparent),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Bottom Stats: 57% allocated | $1,079.50 available
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '57% allocated',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6E7A72),
                ),
              ),
              Text(
                r'$1,079.50 available',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF006C49),
                ),
              ),
            ],
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
              minHeight: 4.5,
              backgroundColor: const Color(0xFFEDE0D4),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsightCard() {
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
                    const Text(
                      'Smart Insight',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4EFE1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Saved 18%',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF006C49),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'You spent less on takeout this week compared to last!',
                  style: TextStyle(
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
