import 'package:flutter/material.dart';

/// 月光纸感设计 token。
abstract final class AppColors {
  static const bg = Color(0xFFF3F6F7);
  static const paper = Color(0xFFFAFCFC);
  static const sheet = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const surface = Color(0xFFEEF2F3);
  static const header = Color(0xFF1F2A2C);
  static const primary = Color(0xFF1F2A2C);

  static const accent = Color(0xFF4FAD9F);
  static const accentDeep = Color(0xFF3A8F83);
  static const accentSoft = Color(0xFFE8F6F3);

  static const moon = Color(0xFF7A92A8);
  static const moonSoft = Color(0xFFEEF2F6);

  static const expense = Color(0xFFE07070);
  static const expenseSoft = Color(0xFFFDF1F1);
  static const income = Color(0xFF4FAD9F);
  static const incomeSoft = Color(0xFFE8F6F3);
  static const task = Color(0xFF6B9BC3);
  static const taskSoft = Color(0xFFEEF4F9);
  static const note = Color(0xFF7A92A8);
  static const noteSoft = Color(0xFFEEF2F6);

  static const text = Color(0xFF1F2A2C);
  static const textSecondary = Color(0xFF7A858C);
  static const mute = Color(0xFFC5CDD1);
  static const line = Color(0x0F1F2A2C);

  static const radiusSm = 8.0;
  static const radiusMd = 14.0;
  static const radiusLg = 20.0;
}

/// 构建应用主题。
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.sheet,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'PingFang SC',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.sheet,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    dividerColor: AppColors.line,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
  );
}
