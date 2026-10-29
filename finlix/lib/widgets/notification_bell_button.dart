import 'package:flutter/material.dart';
import '../core/services/notification_service.dart';
import '../core/theme/app_colors.dart';
import 'notification_bottom_sheet.dart';

class NotificationBellButton extends StatelessWidget {
  final void Function(int tabIndex)? onNavigateTab;

  const NotificationBellButton({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationService.instance.unreadCountNotifier,
      builder: (context, unreadCount, _) {
        return Tooltip(
          message: 'Pusat Notifikasi',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                NotificationBottomSheet.show(
                  context,
                  onNavigateTab: onNavigateTab,
                );
              },
              borderRadius: BorderRadius.circular(19),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.peachAccentBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.peachAccentBorder,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.onSurface,
                      size: 20,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: AppColors.expense,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.8,
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
  }
}
