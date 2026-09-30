import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analitik', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Text(
          'Analytics Screen',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}
