import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'dashboard/dashboard_screen.dart';
import 'analytics/analytics_screen.dart';
import 'savings/savings_screen.dart';
import 'profile/profile_screen.dart';
import 'transactions/add_transaction_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey<DashboardScreenState>();
  final GlobalKey<AnalyticsScreenState> _analyticsKey = GlobalKey<AnalyticsScreenState>();
  final GlobalKey<SavingsScreenState> _savingsKey = GlobalKey<SavingsScreenState>();

  late final List<Widget> _screens = [
    DashboardScreen(key: _dashboardKey),
    AnalyticsScreen(key: _analyticsKey),
    SavingsScreen(key: _savingsKey),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            _dashboardKey.currentState?.loadData();
          } else if (index == 1) {
            _analyticsKey.currentState?.loadData();
          } else if (index == 2) {
            _savingsKey.currentState?.loadData();
          }
        },
        onAddTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );

          if (result == true) {
            _dashboardKey.currentState?.loadData();
            _analyticsKey.currentState?.loadData();
            _savingsKey.currentState?.loadData();
          }
        },
      ),
    );
  }
}

