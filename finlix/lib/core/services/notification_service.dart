import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../models/transaction_model.dart';
import '../data/default_categories.dart';
import '../database/db_helper.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();

  NotificationService._init();

  /// Reactive notifier for unread notification count across app headers
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  /// Cached list of current notifications
  List<NotificationItem> _currentNotifications = [];

  List<NotificationItem> get currentNotifications => _currentNotifications;

  /// Generate smart notifications from real SQLite data
  Future<List<NotificationItem>> getNotifications() async {
    try {
      final now = DateTime.now();

      // Fetch dependencies in parallel
      final results = await Future.wait([
        DbHelper.instance.getAllTransactions(),
        DbHelper.instance.getAllSavingsGoals(),
        DbHelper.instance.getMonthlyBudget(),
        DbHelper.instance.getUserProfile(),
        DbHelper.instance.getSetting('read_notifications'),
        DbHelper.instance.getSetting('cleared_notifications'),
      ]);

      final transactions = results[0] as List<TransactionModel>;
      final savingsGoals = results[1] as dynamic; // List<SavingsGoalModel>
      final monthlyBudget = results[2] as double;
      final profile = results[3] as Map<String, String>;
      final readStr = (results[4] as String?) ?? '';
      final clearedStr = (results[5] as String?) ?? '';

      final readIds = readStr.split(',').where((s) => s.isNotEmpty).toSet();
      final clearedIds = clearedStr.split(',').where((s) => s.isNotEmpty).toSet();

      final List<NotificationItem> items = [];

      // 1. Filter current month transactions
      final monthTransactions = transactions.where((t) {
        return t.date.year == now.year && t.date.month == now.month;
      }).toList();

      final totalMonthExpenses = monthTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      final isBudgetAlertEnabled = profile['budget_alert_enabled'] != 'false';

      // ----------------------------------------------------
      // A. BUDGET ALERTS (Overbudget & 80%+ Warning)
      // ----------------------------------------------------
      if (isBudgetAlertEnabled && monthlyBudget > 0 && totalMonthExpenses > 0) {
        final ratio = totalMonthExpenses / monthlyBudget;

        if (ratio >= 1.0) {
          final id = 'budget_over_${now.year}_${now.month}';
          items.add(NotificationItem(
            id: id,
            title: 'Anggaran Terlampaui! 🚨',
            message:
                'Pengeluaran bulan ini (${AppFormatters.formatCurrency(totalMonthExpenses)}) telah melebihi batas anggaran (${AppFormatters.formatCurrency(monthlyBudget)}).',
            type: NotificationType.budgetAlert,
            timestamp: now,
            actionTab: 1, // Analytics
            actionLabel: 'Cek Analitik',
            icon: Icons.warning_rounded,
            iconColor: AppColors.expense,
            backgroundColor: const Color(0xFFFFECE5),
            categoryTag: 'Anggaran',
          ));
        } else if (ratio >= 0.8) {
          final id = 'budget_near_${now.year}_${now.month}';
          final sisa = monthlyBudget - totalMonthExpenses;
          items.add(NotificationItem(
            id: id,
            title: 'Mendekati Batas Anggaran (80%+)',
            message:
                'Pengeluaran sudah ${(ratio * 100).toStringAsFixed(0)}% dari limit. Sisa anggaran aman Anda: ${AppFormatters.formatCurrency(sisa)}.',
            type: NotificationType.budgetAlert,
            timestamp: now,
            actionTab: 1, // Analytics
            actionLabel: 'Cek Anggaran',
            icon: Icons.report_problem_outlined,
            iconColor: const Color(0xFFD97706), // Amber
            backgroundColor: const Color(0xFFFFF4E5),
            categoryTag: 'Anggaran',
          ));
        }
      }

      // ----------------------------------------------------
      // B. POTS & SAVINGS MILESTONES
      // ----------------------------------------------------
      for (final goal in savingsGoals) {
        final target = goal.targetAmount as double;
        final current = goal.currentAmount as double;
        final isCompleted = goal.isCompleted as bool;
        final progress = goal.progressPercent as double;
        final title = goal.title as String;
        final goalId = goal.id.toString();

        if (isCompleted || current >= target) {
          final id = 'pot_done_$goalId';
          items.add(NotificationItem(
            id: id,
            title: 'Target Tabungan Tercapai! 🎉',
            message:
                'Hebat! Target "$title" sebesar ${AppFormatters.formatCurrency(target)} sudah berhasil terkumpul 100%!',
            type: NotificationType.potMilestone,
            timestamp: now,
            actionTab: 2, // Pots
            actionLabel: 'Buka Pots',
            icon: Icons.celebration_rounded,
            iconColor: AppColors.primary,
            backgroundColor: const Color(0xFFD4EFE1),
            categoryTag: 'Tabungan',
          ));
        } else if (progress >= 0.5) {
          final id = 'pot_half_$goalId';
          items.add(NotificationItem(
            id: id,
            title: 'Milestone 50%+ Tabungan 🎯',
            message:
                'Target "$title" sudah terkumpul ${(progress * 100).toStringAsFixed(0)}% (${AppFormatters.formatCurrency(current)}). Selangkah lagi menuju impianmu!',
            type: NotificationType.potMilestone,
            timestamp: now,
            actionTab: 2, // Pots
            actionLabel: 'Top-up Lagi',
            icon: Icons.flag_rounded,
            iconColor: AppColors.primary,
            backgroundColor: const Color(0xFFD4EFE1),
            categoryTag: 'Tabungan',
          ));
        }
      }

      // ----------------------------------------------------
      // C. PAYDAY REMINDER
      // ----------------------------------------------------
      final salaryDay = int.tryParse(profile['salary_day'] ?? '25') ?? 25;
      if (now.day == salaryDay) {
        final id = 'payday_today_${now.year}_${now.month}_${now.day}';
        items.add(NotificationItem(
          id: id,
          title: 'Hari Gajian Tiba! 💰',
          message:
              'Hari ini adalah tanggal gajianmu. Waktu terbaik untuk mengalokasikan tabungan impian dan merencanakan anggaran bulanan.',
          type: NotificationType.paydayReminder,
          timestamp: now,
          actionTab: 2, // Pots
          actionLabel: 'Alokasi Tabungan',
          icon: Icons.account_balance_wallet_rounded,
          iconColor: AppColors.primary,
          backgroundColor: const Color(0xFFD4EFE1),
          categoryTag: 'Pengingat',
        ));
      } else if (now.day == salaryDay - 1 || (salaryDay == 1 && now.day >= 28)) {
        final id = 'payday_eve_${now.year}_${now.month}_${now.day}';
        items.add(NotificationItem(
          id: id,
          title: 'Besok Hari Gajian! 🗓️',
          message:
              'Besok adalah tanggal gajianmu. Siapkan catatan keuanganmu agar cashflow tetap sehat dan terkontrol.',
          type: NotificationType.paydayReminder,
          timestamp: now,
          actionTab: 0, // Home
          actionLabel: 'Cek Ringkasan',
          icon: Icons.event_available_rounded,
          iconColor: const Color(0xFF59579A),
          backgroundColor: const Color(0xFFE4E0FF),
          categoryTag: 'Pengingat',
        ));
      }

      // ----------------------------------------------------
      // D. DAILY LOGGING REMINDER (If today has no records)
      // ----------------------------------------------------
      final todayTransactions = transactions.where((t) {
        return t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day;
      }).toList();

      if (todayTransactions.isEmpty) {
        final id = 'daily_log_${now.year}_${now.month}_${now.day}';
        items.add(NotificationItem(
          id: id,
          title: 'Belum Ada Catatan Hari Ini ✍️',
          message:
              'Kamu belum mencatat transaksi hari ini. Luangkan 30 detik untuk mencatat pengeluaran atau pemasukanmu.',
          type: NotificationType.dailyReminder,
          timestamp: now,
          actionTab: 0, // Home
          actionLabel: 'Catat Sekarang',
          icon: Icons.edit_calendar_rounded,
          iconColor: const Color(0xFF59579A),
          backgroundColor: const Color(0xFFE4E0FF),
          categoryTag: 'Pengingat',
        ));
      }

      // ----------------------------------------------------
      // E. TOP SPENDING INSIGHT
      // ----------------------------------------------------
      if (totalMonthExpenses > 0) {
        // Group by category
        final Map<String, double> categorySums = {};
        for (final t in monthTransactions) {
          if (t.type == TransactionType.expense) {
            categorySums[t.categoryId] =
                (categorySums[t.categoryId] ?? 0.0) + t.amount;
          }
        }

        if (categorySums.isNotEmpty) {
          var topCategoryId = categorySums.keys.first;
          var topAmount = categorySums[topCategoryId]!;

          for (final entry in categorySums.entries) {
            if (entry.value > topAmount) {
              topCategoryId = entry.key;
              topAmount = entry.value;
            }
          }

          final catModel = DefaultCategories.byId(topCategoryId);
          final catName = catModel?.name ?? 'Pengeluaran';
          final percent = (topAmount / totalMonthExpenses * 100).toStringAsFixed(0);

          final id = 'top_cat_${now.year}_${now.month}';
          items.add(NotificationItem(
            id: id,
            title: 'Wawasan Pengeluaran Terbesar 💡',
            message:
                'Kategori "$catName" menyumbang $percent% (${AppFormatters.formatCurrency(topAmount)}) dari total pengeluaran bulan ini.',
            type: NotificationType.smartInsight,
            timestamp: now,
            actionTab: 1, // Analytics
            actionLabel: 'Lihat Analisis',
            icon: Icons.lightbulb_outline_rounded,
            iconColor: const Color(0xFFD97706),
            backgroundColor: const Color(0xFFFFF4E5),
            categoryTag: 'Wawasan',
          ));
        }
      }

      // ----------------------------------------------------
      // Filter cleared and map isRead
      // ----------------------------------------------------
      final activeList = items.where((it) => !clearedIds.contains(it.id)).map((it) {
        return it.copyWith(isRead: readIds.contains(it.id));
      }).toList();

      // Sort: Unread first, then by priority / order
      activeList.sort((a, b) {
        if (!a.isRead && b.isRead) return -1;
        if (a.isRead && !b.isRead) return 1;
        return 0;
      });

      _currentNotifications = activeList;

      // Update reactive unread count
      final unreadCount = activeList.where((n) => !n.isRead).length;
      unreadCountNotifier.value = unreadCount;

      return activeList;
    } catch (e) {
      debugPrint('NotificationService error: $e');
      return [];
    }
  }

  /// Mark specific notification as read
  Future<void> markAsRead(String id) async {
    try {
      final saved = await DbHelper.instance.getSetting('read_notifications') ?? '';
      final set = saved.split(',').where((s) => s.isNotEmpty).toSet();
      set.add(id);
      await DbHelper.instance.setSetting('read_notifications', set.join(','));

      // Update in-memory state
      _currentNotifications = _currentNotifications.map((item) {
        if (item.id == id) {
          return item.copyWith(isRead: true);
        }
        return item;
      }).toList();

      unreadCountNotifier.value = _currentNotifications.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint('NotificationService markAsRead error: $e');
    }
  }

  /// Mark all active notifications as read
  Future<void> markAllAsRead() async {
    try {
      final saved = await DbHelper.instance.getSetting('read_notifications') ?? '';
      final set = saved.split(',').where((s) => s.isNotEmpty).toSet();
      for (final n in _currentNotifications) {
        set.add(n.id);
      }
      await DbHelper.instance.setSetting('read_notifications', set.join(','));

      _currentNotifications = _currentNotifications.map((item) {
        return item.copyWith(isRead: true);
      }).toList();

      unreadCountNotifier.value = 0;
    } catch (e) {
      debugPrint('NotificationService markAllAsRead error: $e');
    }
  }

  /// Clear all notifications (dismiss)
  Future<void> clearAllNotifications() async {
    try {
      final saved = await DbHelper.instance.getSetting('cleared_notifications') ?? '';
      final set = saved.split(',').where((s) => s.isNotEmpty).toSet();
      for (final n in _currentNotifications) {
        set.add(n.id);
      }
      await DbHelper.instance.setSetting('cleared_notifications', set.join(','));

      _currentNotifications = [];
      unreadCountNotifier.value = 0;
    } catch (e) {
      debugPrint('NotificationService clearAllNotifications error: $e');
    }
  }

  /// Quick check & refresh unread count without full fetch
  Future<int> refreshUnreadCount() async {
    final list = await getNotifications();
    return list.where((n) => !n.isRead).length;
  }
}
