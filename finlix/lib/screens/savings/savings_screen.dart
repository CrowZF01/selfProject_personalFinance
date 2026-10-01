import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  bool _isRoundUpsEnabled = true;

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
                  'FinLix',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Color(0xFF757575),
                  ),
                ),
                Text(
                  'Pots & Goals',
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
              // Total Savings Card
              _buildTotalSavingsCard(),
              const SizedBox(height: 14),

              // Round-Ups Toggle Card
              _buildRoundUpsCard(),
              const SizedBox(height: 18),

              // Your Savings Pots Header
              _buildPotsHeader(),
              const SizedBox(height: 12),

              // 2x2 Grid of Pots
              _buildPotsGrid(),

              // Bottom padding for floating navigation bar
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSavingsCard() {
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
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'TOTAL SAVINGS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Color(0xFF8E4C3B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4EFE1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '4 Pots',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF006C49),
                      ),
                    ),
                  ),
                ],
              ),
              // New Pot Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF7ED9AC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: Color(0xFF00583A),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'New Pot',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00583A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Amount + Monthly Increase
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                r'$8,450',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '.00',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF757575),
                ),
              ),
              SizedBox(width: 10),
              Text(
                r'+ $32.40/mo',
                style: TextStyle(
                  fontSize: 12,
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

  Widget _buildRoundUpsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          // Refresh Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5D9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sync_rounded,
              color: Color(0xFF8E4C3B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Round-Ups into Emergency Fund',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Spare change auto-saved on every purchase',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8E4C3B),
                  ),
                ),
              ],
            ),
          ),

          // Switch / Checkmark Toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _isRoundUpsEnabled = !_isRoundUpsEnabled;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _isRoundUpsEnabled ? const Color(0xFF7ED9AC) : const Color(0xFFE2CFC2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Align(
                alignment: _isRoundUpsEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: _isRoundUpsEnabled
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Color(0xFF006C49),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPotsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Your Savings Pots ',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              TextSpan(
                text: '(4)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E4C3B),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: const [
            Icon(
              Icons.flag_outlined,
              size: 14,
              color: Color(0xFF8E4C3B),
            ),
            SizedBox(width: 4),
            Text(
              r'Target: $10,000',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E4C3B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPotsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPotCard(
                icon: Icons.shield_rounded,
                iconBgColor: const Color(0xFFE0E7FE),
                iconColor: const Color(0xFF4F46E5),
                badgeText: '84%',
                badgeBgColor: const Color(0xFFE0E7FE),
                badgeTextColor: const Color(0xFF4338CA),
                title: 'Emergency Fund',
                savedAmount: r'$4,200',
                targetAmount: r'/ $5,000',
                progress: 4200 / 5000,
                progressBarColor: const Color(0xFF59579A),
                bottomLeftText: r'$800 left',
                bottomRightText: 'On Track',
                bottomRightColor: const Color(0xFF59579A),
                borderColor: const Color(0xFFE0E7FE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPotCard(
                icon: Icons.local_florist_rounded,
                iconBgColor: const Color(0xFFFFE4E6),
                iconColor: const Color(0xFFF43F5E),
                badgeText: '80%',
                badgeBgColor: const Color(0xFFFFE4D6),
                badgeTextColor: const Color(0xFFC2410C),
                title: 'Japan Trip',
                savedAmount: r'$2,800',
                targetAmount: r'/ $3,500',
                progress: 2800 / 3500,
                progressBarColor: const Color(0xFF8E4C3B),
                bottomLeftText: r'$700 left',
                bottomRightText: 'Sep 2025',
                bottomRightColor: const Color(0xFF8E4C3B),
                borderColor: const Color(0xFFF2DDD0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPotCard(
                icon: Icons.laptop_mac_rounded,
                iconBgColor: const Color(0xFFD4EFE1),
                iconColor: const Color(0xFF006C49),
                badgeText: '79%',
                badgeBgColor: const Color(0xFFD4EFE1),
                badgeTextColor: const Color(0xFF047857),
                title: 'Desk Setup',
                savedAmount: r'$950',
                targetAmount: r'/ $1,200',
                progress: 950 / 1200,
                progressBarColor: const Color(0xFF006C49),
                bottomLeftText: r'$250 left',
                bottomRightText: 'Steady',
                bottomRightColor: const Color(0xFF006C49),
                borderColor: const Color(0xFFD4EFE1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPotCard(
                icon: Icons.airplane_ticket_rounded,
                iconBgColor: const Color(0xFFFFD4DF),
                iconColor: const Color(0xFFE11D48),
                badgeText: '100% ✓',
                badgeBgColor: const Color(0xFFD4EFE1),
                badgeTextColor: const Color(0xFF006C49),
                title: 'Concert Tickets',
                savedAmount: r'$300',
                targetAmount: r'/ $300 Goal',
                progress: 1.0,
                progressBarColor: const Color(0xFF006C49),
                bottomLeftText: 'Goal Reached!',
                bottomLeftColor: const Color(0xFF006C49),
                isCompleted: true,
                borderColor: const Color(0xFF7ED9AC),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPotCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String badgeText,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required String title,
    required String savedAmount,
    required String targetAmount,
    required double progress,
    required Color progressBarColor,
    required String bottomLeftText,
    Color? bottomLeftColor,
    String? bottomRightText,
    Color? bottomRightColor,
    bool isCompleted = false,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF1E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Icon + Percentage badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Pot Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Amounts
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                savedAmount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  targetAmount,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? const Color(0xFF006C49) : const Color(0xFF757575),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: const Color(0xFFEDE0D4),
              valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
            ),
          ),
          const SizedBox(height: 8),

          // Bottom Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bottomLeftText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
                  color: bottomLeftColor ?? const Color(0xFF757575),
                ),
              ),
              if (isCompleted)
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 15,
                  color: Color(0xFF006C49),
                )
              else if (bottomRightText != null)
                Text(
                  bottomRightText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: bottomRightColor ?? const Color(0xFF757575),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
