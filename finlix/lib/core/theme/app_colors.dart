import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppColors {
  static bool get isDark => AppTheme.isDark;

  // Surfaces & Backgrounds
  static Color get background =>
      isDark ? const Color(0xFF131715) : const Color(0xFFFBF4EE);
  static Color get surface =>
      isDark ? const Color(0xFF1C231F) : const Color(0xFFFAF1E8);
  static Color get surfaceDim =>
      isDark ? const Color(0xFF171D1A) : const Color(0xFFF0E4DA);
  static Color get surfaceContainerLowest =>
      isDark ? const Color(0xFF171D1A) : const Color(0xFFFFFFFF);
  static Color get surfaceContainerLow =>
      isDark ? const Color(0xFF1E2622) : const Color(0xFFFAF2EB);
  static Color get surfaceContainer =>
      isDark ? const Color(0xFF222B26) : const Color(0xFFF5EBE1);
  static Color get surfaceContainerHigh =>
      isDark ? const Color(0xFF28342E) : const Color(0xFFEFE2D6);
  static Color get surfaceContainerHighest =>
      isDark ? const Color(0xFF2E3C35) : const Color(0xFFE8D7C9);

  // Border & Dividers
  static Color get borderSubtle =>
      isDark ? const Color(0xFF2C3831) : const Color(0xFFF2DDD0);
  static Color get divider =>
      isDark ? const Color(0xFF26302A) : const Color(0xFFF0E0D4);

  // Text & Content
  static Color get onSurface =>
      isDark ? const Color(0xFFF0F4F2) : const Color(0xFF1E1E1E);
  static Color get onSurfaceVariant =>
      isDark ? const Color(0xFF9BA8A1) : const Color(0xFF6E7A72);
  static Color get outline =>
      isDark ? const Color(0xFF68786F) : const Color(0xFF8E9A92);
  static Color get outlineVariant =>
      isDark ? const Color(0xFF38463E) : const Color(0xFFD8CDC4);

  // Status & Transactions
  static Color get primary =>
      isDark ? const Color(0xFF38B281) : const Color(0xFF006C49);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static Color get expense =>
      isDark ? const Color(0xFFF25A4B) : const Color(0xFFBD382B);
  static Color get income =>
      isDark ? const Color(0xFF38B281) : const Color(0xFF006C49);

  // Category Pastel Backgrounds
  static Color get pastelPeach =>
      isDark ? const Color(0xFF3E241E) : const Color(0xFFFFD9CE);
  static Color get pastelMint =>
      isDark ? const Color(0xFF1D382B) : const Color(0xFFD4EFE1);
  static Color get pastelPurple =>
      isDark ? const Color(0xFF2B2844) : const Color(0xFFE4E0FF);
  static Color get pastelOrange =>
      isDark ? const Color(0xFF3D291D) : const Color(0xFFFFDED4);

  // Category Icon Foreground Colors
  static Color get iconPeach =>
      isDark ? const Color(0xFFFFA18E) : const Color(0xFFBD382B);
  static Color get iconMint =>
      isDark ? const Color(0xFF38B281) : const Color(0xFF006C49);
  static Color get iconPurple =>
      isDark ? const Color(0xFFAFA9FF) : const Color(0xFF59579A);

  // Common UI Color Adapters
  static Color get cardSurface =>
      isDark ? const Color(0xFF1C231F) : const Color(0xFFFAF1E8);
  static Color get cardSurfaceAlt =>
      isDark ? const Color(0xFF1E2622) : const Color(0xFFFAF2EB);
  static Color get chipSurface =>
      isDark ? const Color(0xFF242F29) : const Color(0xFFF0E4DA);
  static Color get peachAccentBg =>
      isDark ? const Color(0xFF2C221E) : const Color(0xFFFFF0E6);
  static Color get peachAccentBorder =>
      isDark ? const Color(0xFF3E2D27) : const Color(0xFFF3D5C8);
  static Color get mintAccentBg =>
      isDark ? const Color(0xFF1D382B) : const Color(0xFFD4EFE1);
  static Color get mintAccentBorder =>
      isDark ? const Color(0xFF2E4D3C) : const Color(0xFFBCE3CE);
  static Color get textMuted =>
      isDark ? const Color(0xFF9BA8A1) : const Color(0xFF757575);
}
