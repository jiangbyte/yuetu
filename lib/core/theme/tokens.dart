import 'package:flutter/painting.dart';

/// Design Token：滴答清单风格色板与尺度。
abstract final class AppColors {
  static const Color primary = Color(0xFF4A7DFF);
  static const Color primaryPressed = Color(0xFF3A6AE6);
  static const Color primarySoft = Color(0xFFE8F0FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color canvas = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1F2329);
  static const Color inkMuted = Color(0xFF8A9199);
  static const Color expense = Color(0xFFF24822);
  static const Color income = Color(0xFF00B42A);
  static const Color checkin = Color(0xFF00B42A);
  static const Color stroke = Color(0xFFEBEDF0);
  static const Color chipIdle = Color(0xFFFFFFFF);
  static const Color chipSelected = Color(0xFFEEF0F3);
}

/// 字号与字重。
abstract final class AppTypography {
  static const double display = 28;
  static const double pageTitle = 20;
  static const double title = 18;
  static const double body = 16;
  static const double label = 15;
  static const double caption = 13;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w600;
}

/// 间距。
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double page = 20;
}

/// 圆角。
abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double pill = 999;
}
