import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../core/services/notification_service.dart';
import '../core/theme/app_colors.dart';

class NotificationBottomSheet {
  static Future<void> show(
    BuildContext context, {
    void Function(int tabIndex)? onNavigateTab,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NotificationBottomSheetContent(
        onNavigateTab: onNavigateTab,
      ),
    );
  }
}

class _NotificationBottomSheetContent extends StatefulWidget {
  final void Function(int tabIndex)? onNavigateTab;

  const _NotificationBottomSheetContent({this.onNavigateTab});

  @override
  State<_NotificationBottomSheetContent> createState() =>
      _NotificationBottomSheetContentState();
}

class _NotificationBottomSheetContentState
    extends State<_NotificationBottomSheetContent> {
  bool _isLoading = true;
  List<NotificationItem> _notifications = [];
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Anggaran',
    'Tabungan',
    'Pengingat',
    'Wawasan',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final items = await NotificationService.instance.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = items;
        _isLoading = false;
      });
    }
  }

  List<NotificationItem> get _filteredNotifications {
    if (_selectedCategory == 'Semua') {
      return _notifications;
    }
    return _notifications
        .where((item) => item.categoryTag == _selectedCategory)
        .toList();
  }

  int get _unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  Future<void> _markAllAsRead() async {
    await NotificationService.instance.markAllAsRead();
    if (mounted) {
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Semua notifikasi telah ditandai dibaca'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Bersihkan Notifikasi?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'Semua daftar notifikasi dan wawasan saat ini akan dihapus dari riwayat.',
          style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6E7A72))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await NotificationService.instance.clearAllNotifications();
      if (mounted) {
        setState(() {
          _notifications = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxSheetHeight = mediaQuery.size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
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
            const SizedBox(height: 14),

            // Top Header: Title, Unread Count & Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Title + Badge
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Pusat Notifikasi',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (_unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFECE5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFF3D5C8),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '$_unreadCount Baru',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.expense,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Mark All Read Button
                  if (_unreadCount > 0)
                    IconButton(
                      tooltip: 'Tandai Semua Dibaca',
                      icon: Icon(
                        Icons.done_all_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      onPressed: _markAllAsRead,
                    ),

                  // Clear All Button
                  if (_notifications.isNotEmpty)
                    IconButton(
                      tooltip: 'Bersihkan Riwayat',
                      icon: const Icon(
                        Icons.delete_sweep_outlined,
                        size: 21,
                        color: Color(0xFF8E9A92),
                      ),
                      onPressed: _clearAll,
                    ),

                  // Close Button
                  IconButton(
                    tooltip: 'Tutup',
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: Color(0xFF757575),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Category Filter Chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : const Color(0xFFF0E4DA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : const Color(0xFFE2CFC2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),
            Divider(height: 1, color: AppColors.divider),

            // Content List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : _filteredNotifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          itemCount: _filteredNotifications.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _filteredNotifications[index];
                            return _buildNotificationCard(item);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFD4EFE1), // Pastel mint
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_outlined,
                color: AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Semua Beres! 🎉',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedCategory == 'Semua'
                  ? 'Tidak ada peringatan atau pengingat aktif saat ini. Keuangan Anda aman dan terkendali.'
                  : 'Tidak ada notifikasi dalam kategori "$_selectedCategory".',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    final isUnread = !item.isRead;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (isUnread) {
            await NotificationService.instance.markAsRead(item.id);
            setState(() {
              _notifications = _notifications.map((n) {
                if (n.id == item.id) return n.copyWith(isRead: true);
                return n;
              }).toList();
            });
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread
                ? (AppColors.isDark ? const Color(0xFF222B26) : const Color(0xFFFFFDFC))
                : AppColors.cardSurfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? item.iconColor.withValues(alpha: 0.35)
                  : AppColors.borderSubtle,
              width: isUnread ? 1.4 : 1,
            ),
            boxShadow: isUnread
                ? [
                    BoxShadow(
                      color: item.iconColor.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Icon + Category Tag + Relative Time + Unread Dot
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: item.backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: item.iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Tag Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E4DA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.categoryTag.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: item.iconColor,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Relative Time
                  const Text(
                    'Hari ini',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8E9A92),
                    ),
                  ),

                  // Unread Indicator Dot
                  if (isUnread) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.expense,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 10),

              // Title
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                  color: AppColors.onSurface,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 5),

              // Message
              Text(
                item.message,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurfaceVariant,
                  height: 1.35,
                ),
              ),

              // Action Button (if any)
              if (item.actionTab != null && item.actionLabel != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () async {
                      // Mark as read
                      if (isUnread) {
                        await NotificationService.instance.markAsRead(item.id);
                      }
                      // Close bottom sheet
                      if (mounted) {
                        Navigator.pop(context);
                      }
                      // Navigate to tab
                      widget.onNavigateTab?.call(item.actionTab!);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: item.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: item.iconColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.actionLabel!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: item.iconColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: item.iconColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
