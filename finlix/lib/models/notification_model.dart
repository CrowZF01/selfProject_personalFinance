import 'package:flutter/material.dart';

enum NotificationType {
  budgetAlert,
  potMilestone,
  paydayReminder,
  dailyReminder,
  smartInsight,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final int? actionTab; // 0: Home, 1: Analytics, 2: Pots, 3: Profile
  final String? actionLabel;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String categoryTag; // 'Anggaran', 'Tabungan', 'Pengingat', 'Wawasan'

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionTab,
    this.actionLabel,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.categoryTag,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    int? actionTab,
    String? actionLabel,
    IconData? icon,
    Color? iconColor,
    Color? backgroundColor,
    String? categoryTag,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionTab: actionTab ?? this.actionTab,
      actionLabel: actionLabel ?? this.actionLabel,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      categoryTag: categoryTag ?? this.categoryTag,
    );
  }
}
