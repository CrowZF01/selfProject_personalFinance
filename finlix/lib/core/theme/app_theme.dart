import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'app_colors.dart';

class AppTheme {
  static final ValueNotifier<String> themeNotifier =
      ValueNotifier<String>('warm_peach');

  static bool get isDark => themeNotifier.value == 'dark';

  static Future<void> init() async {
    try {
      final saved = await DbHelper.instance.getSetting('app_theme');
      if (saved != null && saved.isNotEmpty) {
        themeNotifier.value = saved;
      }
    } catch (_) {}
  }

  static Future<void> setTheme(String theme) async {
    themeNotifier.value = theme;
    await DbHelper.instance.setSetting('app_theme', theme);
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme(
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
      appBarTheme: AppBarTheme(
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
          side: BorderSide(color: AppColors.borderSubtle, width: 1.2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF131715),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF38B281),
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF1E382B),
        onPrimaryContainer: Color(0xFF8CE3BA),
        secondary: Color(0xFF8C88E0),
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF2C284A),
        onSecondaryContainer: Color(0xFFCEC9FF),
        tertiary: Color(0xFFF25A4B),
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFF4A1F1B),
        onTertiaryContainer: Color(0xFFFFB4AB),
        error: Color(0xFFF25A4B),
        onError: Colors.white,
        errorContainer: Color(0xFF4A1F1B),
        onErrorContainer: Color(0xFFFFB4AB),
        surface: Color(0xFF1C221F),
        onSurface: Color(0xFFF0F4F2),
        onSurfaceVariant: Color(0xFF9BA7A0),
        outline: Color(0xFF5E6D65),
        outlineVariant: Color(0xFF35403A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF131715),
        foregroundColor: Color(0xFFF0F4F2),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E2622),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2C3731), width: 1.2),
        ),
      ),
    );
  }
}

