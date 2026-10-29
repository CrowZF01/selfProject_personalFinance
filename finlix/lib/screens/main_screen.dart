import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'dashboard/dashboard_screen.dart';
import 'analytics/analytics_screen.dart';
import 'savings/savings_screen.dart';
import 'profile/profile_screen.dart';
import 'transactions/add_transaction_screen.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../core/services/notification_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  GlobalKey<DashboardScreenState>? _dashboardKey;
  GlobalKey<AnalyticsScreenState>? _analyticsKey;
  GlobalKey<SavingsScreenState>? _savingsKey;
  GlobalKey<ProfileScreenState>? _profileKey;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.refreshUnreadCount();
  }

  GlobalKey<DashboardScreenState> get dashboardKey =>
      _dashboardKey ??= GlobalKey<DashboardScreenState>();
  GlobalKey<AnalyticsScreenState> get analyticsKey =>
      _analyticsKey ??= GlobalKey<AnalyticsScreenState>();
  GlobalKey<SavingsScreenState> get savingsKey =>
      _savingsKey ??= GlobalKey<SavingsScreenState>();
  GlobalKey<ProfileScreenState> get profileKey =>
      _profileKey ??= GlobalKey<ProfileScreenState>();

  void _switchTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
    if (index == 0) {
      dashboardKey.currentState?.loadData();
    } else if (index == 1) {
      analyticsKey.currentState?.loadData();
    } else if (index == 2) {
      savingsKey.currentState?.loadData();
    } else if (index == 3) {
      profileKey.currentState?.loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        AppFormatters.currencyNotifier,
        AppTheme.themeNotifier,
      ]),
      builder: (context, _) {
        final screens = [
          DashboardScreen(
            key: dashboardKey,
            onHomeTap: () => _switchTab(0),
            onProfileTap: () => _switchTab(3),
            onNavigateTab: _switchTab,
          ),
          AnalyticsScreen(
            key: analyticsKey,
            onHomeTap: () => _switchTab(0),
            onProfileTap: () => _switchTab(3),
            onNavigateTab: _switchTab,
          ),
          SavingsScreen(
            key: savingsKey,
            onHomeTap: () => _switchTab(0),
            onProfileTap: () => _switchTab(3),
            onNavigateTab: _switchTab,
          ),
          ProfileScreen(
            key: profileKey,
            onHomeTap: () => _switchTab(0),
            onProfileTap: () => _switchTab(3),
            onNavigateTab: _switchTab,
          ),
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _switchTab,
            onAddTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              );

              if (result == true) {
                dashboardKey.currentState?.loadData();
                analyticsKey.currentState?.loadData();
                savingsKey.currentState?.loadData();
                profileKey.currentState?.loadData();
                NotificationService.instance.refreshUnreadCount();
              }
            },
          ),
        );
      },
    );
  }
}

