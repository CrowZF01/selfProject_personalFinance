import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.pastelMint,
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.iconPurple,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.pastelPurple,
        onSecondaryContainer: AppColors.iconPurple,
        tertiary: AppColors.expense,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.pastelPeach,
        onTertiaryContainer: AppColors.expense,
        error: AppColors.expense,
        onError: Colors.white,
        errorContainer: AppColors.pastelPeach,
        onErrorContainer: AppColors.expense,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.2),
        ),
      ),
    );
  }
}

