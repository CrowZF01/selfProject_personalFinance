import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/database/db_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/savings_goal_model.dart';
import '../../widgets/notification_bell_button.dart';
import '../../core/services/notification_service.dart';

class SavingsScreen extends StatefulWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onProfileTap;
  final void Function(int tabIndex)? onNavigateTab;

  const SavingsScreen({
    super.key,
    this.onHomeTap,
    this.onProfileTap,
    this.onNavigateTab,
  });

  @override
  State<SavingsScreen> createState() => SavingsScreenState();
}

class SavingsScreenState extends State<SavingsScreen> {
  bool _isRoundUpsEnabled = true;
  List<SavingsGoalModel> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// Memuat data tabungan dari SQLite
  Future<void> loadData() async {
    setState(() => _isLoading = true);
    try {
      // Seed default pots jika tabel kosong
      // await DbHelper.instance.seedDefaultSavingsGoalsIfEmpty();
      final data = await DbHelper.instance.getAllSavingsGoals();
      NotificationService.instance.refreshUnreadCount();
      if (mounted) {
        setState(() {
          _goals = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatCompact(double? amount) {
    return AppFormatters.formatCompact(amount);
  }

  @override
  Widget build(BuildContext context) {
    double totalSaved = 0;
    double totalTarget = 0;
    for (var g in _goals) {
      totalSaved += g.currentAmount;
      totalTarget += g.targetAmount;
    }

    final double overallProgress = totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

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
                      // Total Savings Card
                      _buildTotalSavingsCard(
                        totalSaved: totalSaved,
                        totalTarget: totalTarget,
                        overallProgress: overallProgress,
                      ),
                      const SizedBox(height: 14),

                      // Round-Ups Toggle Card
                      _buildRoundUpsCard(),
                      const SizedBox(height: 18),

                      // Your Savings Pots Header
                      _buildPotsHeader(totalTarget: totalTarget),
                      const SizedBox(height: 12),

                      // Dynamic Grid of Pots or Empty State
                      if (_goals.isEmpty)
                        _buildEmptyPotsState()
                      else
                        _buildPotsGrid(),

                      // Bottom padding for floating navigation bar
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTotalSavingsCard({
    required double totalSaved,
    required double totalTarget,
    required double overallProgress,
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
          // Top Row: Title + Pots Count badge + New Pot Button
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
                    child: Text(
                      '${_goals.length} ${_goals.length == 1 ? "Pot" : "Pots"}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF006C49),
                      ),
                    ),
                  ),
                ],
              ),

              // Interactive New Pot Button
              InkWell(
                onTap: _showCreatePotModal,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7ED9AC),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF006C49).withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                AppFormatters.isIdr
                    ? AppFormatters.formatCurrency(totalSaved)
                    : _formatCompact(totalSaved),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              if (!AppFormatters.isIdr)
                Text(
                  '.${(totalSaved % 1 * 100).toInt().toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF757575),
                  ),
                ),
              const SizedBox(width: 10),
              if (totalTarget > 0)
                Text(
                  '${(overallProgress * 100).toStringAsFixed(0)}% of goal',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF006C49),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Overall Target Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: overallProgress,
              minHeight: 7,
              backgroundColor: const Color(0xFFEDE0D4),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),

          // Target Info Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: ${AppFormatters.formatCurrency(totalTarget)}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6E7A72),
                ),
              ),
              Text(
                totalTarget > totalSaved
                    ? '${AppFormatters.formatCurrency(totalTarget - totalSaved)} needed'
                    : 'All Goals Funded! 🎉',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: totalTarget > totalSaved ? const Color(0xFF8E4C3B) : const Color(0xFF006C49),
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
            decoration: const BoxDecoration(
              color: Color(0xFFFFE5D9),
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
                  'Round to Emergency Fund',
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

  Widget _buildPotsHeader({required double totalTarget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Your Savings Pots ',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              TextSpan(
                text: '(${_goals.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E4C3B),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Icon(
              Icons.flag_outlined,
              size: 14,
              color: Color(0xFF8E4C3B),
            ),
            const SizedBox(width: 4),
            Text(
              'Target: ${_formatCompact(totalTarget)}',
              style: const TextStyle(
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

  Widget _buildEmptyPotsState() {
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
              Icons.savings_rounded,
              color: Color(0xFF006C49),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Savings Pots Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start saving for your dreams! Create separate pots for emergencies, travel, gadgets, or personal goals.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF757575),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _showCreatePotModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Create First Pot',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPotsGrid() {
    // Bangun Grid 2 kolom berpasangan
    final List<Widget> rows = [];
    for (int i = 0; i < _goals.length; i += 2) {
      final goal1 = _goals[i];
      final goal2 = (i + 1 < _goals.length) ? _goals[i + 1] : null;

      rows.add(
        Row(
          children: [
            Expanded(
              child: _buildPotCard(goal: goal1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: goal2 != null ? _buildPotCard(goal: goal2) : const SizedBox(),
            ),
          ],
        ),
      );
      if (i + 2 < _goals.length) {
        rows.add(const SizedBox(height: 12));
      }
    }

    return Column(children: rows);
  }

  Widget _buildPotCard({required SavingsGoalModel goal}) {
    final bool isCompleted = goal.isCompleted;
    final double progress = goal.progress;
    final double percent = goal.progressPercent;
    final remaining = goal.remainingAmount;

    // Menentukan tema warna berdasarkan completion & index
    final Color progressColor = isCompleted
        ? const Color(0xFF006C49)
        : (percent >= 70 ? const Color(0xFF006C49) : const Color(0xFF8E4C3B));

    final Color borderColor = isCompleted
        ? const Color(0xFF7ED9AC)
        : (percent >= 70 ? const Color(0xFFD4EFE1) : const Color(0xFFF2DDD0));

    final Color badgeBg = isCompleted
        ? const Color(0xFFD4EFE1)
        : (percent >= 70 ? const Color(0xFFE0E7FE) : const Color(0xFFFFE4D6));

    final Color badgeText = isCompleted
        ? const Color(0xFF006C49)
        : (percent >= 70 ? const Color(0xFF4338CA) : const Color(0xFFC2410C));

    String targetDateText = 'No date';
    if (goal.targetDate != null) {
      targetDateText = DateFormat('MMM yyyy').format(goal.targetDate!);
    }

    return InkWell(
      onTap: () => _showPotActionsModal(goal),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF1E8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Emoji avatar + Percentage badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFFD4EFE1)
                        : const Color(0xFFFFECE5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    goal.emoji,
                    style: const TextStyle(fontSize: 19),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isCompleted ? '100% ✓' : '${percent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Pot Title
            Text(
              goal.title,
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
                  AppFormatters.formatCompact(goal.currentAmount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    '/ ${AppFormatters.formatCompact(goal.targetAmount)}',
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
                value: progress,
                minHeight: 5,
                backgroundColor: const Color(0xFFEDE0D4),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 8),

            // Bottom Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCompleted ? 'Goal Reached!' : '${AppFormatters.formatCompact(remaining)} left',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
                    color: isCompleted ? const Color(0xFF006C49) : const Color(0xFF757575),
                  ),
                ),
                if (isCompleted)
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 15,
                    color: Color(0xFF006C49),
                  )
                else
                  Text(
                    targetDateText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8E4C3B),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog / Modal Action saat Pot ditekan (Top-up, Detail, Hapus)
  void _showPotActionsModal(SavingsGoalModel goal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
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
              const SizedBox(height: 18),

              // Header Pot Info
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7F0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      goal.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${AppFormatters.formatCurrency(goal.currentAmount)} of ${AppFormatters.formatCurrency(goal.targetAmount)} (${goal.progressPercent.toStringAsFixed(1)}%)',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Action Buttons
              Row(
                children: [
                  // Top Up Button
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
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        _showTopUpDialog(goal);
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                      label: const Text(
                        'Top-Up Saldo',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Delete Button
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
                      _confirmDeletePot(goal);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    tooltip: 'Hapus Pot',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Dialog Input Top Up Dana ke Pot
  void _showTopUpDialog(SavingsGoalModel goal) {
    final controller = TextEditingController();
    final quickAmounts = AppFormatters.isIdr
        ? [10000.0, 50000.0, 100000.0, 250000.0]
        : [10.0, 50.0, 100.0, 250.0];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCC8BB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Top-Up: ${goal.title}',
                          style: const TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(goal.emoji, style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sisa target: ${AppFormatters.formatCurrency(goal.remainingAmount)}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Chips
                    Wrap(
                      spacing: 8,
                      children: quickAmounts.map((amt) {
                        return ActionChip(
                          label: Text(
                            '+${AppFormatters.formatCompact(amt)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                          backgroundColor: const Color(0xFFE8F7F0),
                          side: const BorderSide(color: Color(0xFFCBEBD8)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onPressed: () {
                            setModalState(() {
                              controller.text = amt.toStringAsFixed(0);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Custom Input Field
                    TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
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
                        hintText: '0.00',
                        filled: true,
                        fillColor: const Color(0xFFFAF2EB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2CFC2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2CFC2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirm Top-up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final amount = double.tryParse(controller.text.trim()) ?? 0.0;
                          if (amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Masukkan nominal top-up yang valid')),
                            );
                            return;
                          }

                          final messenger = ScaffoldMessenger.of(context);
                          if (goal.id != null) {
                            await DbHelper.instance.topUpSavingsGoal(goal.id!, amount);
                            await loadData();
                          }
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Berhasil menambah ${AppFormatters.formatCurrency(amount)} ke ${goal.title}!'),
                                backgroundColor: const Color(0xFF006C49),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Konfirmasi Tambah Saldo',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Konfirmasi Hapus Pot
  void _confirmDeletePot(SavingsGoalModel goal) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Hapus ${goal.title}?',
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.onSurface),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus pot tabungan "${goal.title}"? Tindakan ini tidak dapat dibatalkan.',
            style: const TextStyle(color: Color(0xFF757575), fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF757575))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBD382B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (goal.id != null) {
                  await DbHelper.instance.deleteSavingsGoal(goal.id!);
                  await loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pot "${goal.title}" berhasil dihapus.')),
                    );
                  }
                }
              },
              child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  /// Modal Pembuatan Pot Tabungan Baru (New Pot)
  void _showCreatePotModal() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final initialController = TextEditingController();
    DateTime? selectedDate;
    String selectedEmoji = '🎯';

    final sampleEmojis = [
      '🎯', '🛡️', '🌸', '💻', '🎟️', '✈️', '🚗', '🏠', '🎓', '💍', '🎁', '💰', '👟', '🎮'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 42,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCC8BB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create New Pot',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF757575)),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Emoji Selector
                    const Text(
                      'PILIH EMOJI / IKON',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Color(0xFF6E7A72),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: sampleEmojis.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final emoji = sampleEmojis[index];
                          final isSelected = emoji == selectedEmoji;
                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedEmoji = emoji;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFE8F7F0) : const Color(0xFFFAF2EB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : const Color(0xFFE2CFC2),
                                  width: isSelected ? 1.8 : 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Title Input
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Nama Tabungan / Impian',
                        hintText: 'mis. Liburan ke Bali, MacBook Pro',
                        filled: true,
                        fillColor: const Color(0xFFFAF2EB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2CFC2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2CFC2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Target Amount & Initial Amount Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: targetController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: AppFormatters.isIdr ? 'Target Total (Rp)' : 'Target Total (\$)',
                              hintText: AppFormatters.isIdr ? '1000000' : '500.00',
                              filled: true,
                              fillColor: const Color(0xFFFAF2EB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE2CFC2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE2CFC2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: initialController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: AppFormatters.isIdr ? 'Saldo Awal (Rp)' : 'Saldo Awal (\$)',
                              hintText: AppFormatters.isIdr ? '0' : '0.00',
                              filled: true,
                              fillColor: const Color(0xFFFAF2EB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE2CFC2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE2CFC2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Target Date Picker Button
                    InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? now.add(const Duration(days: 90)),
                          firstDate: now,
                          lastDate: DateTime(now.year + 10),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF2EB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2CFC2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_outlined, size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedDate != null
                                    ? 'Target Selesai: ${DateFormat('d MMMM yyyy').format(selectedDate!)}'
                                    : 'Pilih Target Tanggal (Opsional)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: selectedDate != null ? AppColors.onSurface : const Color(0xFF757575),
                                  fontWeight: selectedDate != null ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (selectedDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 16),
                                onPressed: () {
                                  setModalState(() {
                                    selectedDate = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final target = double.tryParse(targetController.text.trim()) ?? 0.0;
                          final initial = double.tryParse(initialController.text.trim()) ?? 0.0;

                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nama tabungan tidak boleh kosong')),
                            );
                            return;
                          }

                          if (target <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Target nominal harus lebih besar dari 0')),
                            );
                            return;
                          }

                          final newGoal = SavingsGoalModel(
                            title: title,
                            targetAmount: target,
                            currentAmount: initial,
                            emoji: selectedEmoji,
                            targetDate: selectedDate,
                          );

                          final messenger = ScaffoldMessenger.of(context);
                          await DbHelper.instance.insertSavingsGoal(newGoal);
                          await loadData();

                          if (bottomSheetContext.mounted) {
                            Navigator.pop(bottomSheetContext);
                          }

                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Pot "$title" berhasil dibuat!'),
                                backgroundColor: const Color(0xFF006C49),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Simpan Target Pot',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
