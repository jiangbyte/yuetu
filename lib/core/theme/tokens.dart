import 'package:flutter/painting.dart';

/// Design Token：色板、字号、间距与圆角，供主题与自建组件共用。
abstract final class AppColors {
  static const Color ink = Color(0xFF1A2332);
  static const Color inkMuted = Color(0xFF5A6578);
  static const Color canvas = Color(0xFFF3F6F9);
  static const Color canvasDeep = Color(0xFFE4EAF1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF2F6F6A);
  static const Color accentPressed = Color(0xFF245853);
  static const Color onAccent = Color(0xFFF7FBFA);
  static const Color stroke = Color(0xFFD0D8E2);
}

/// 字号与字重约定。
abstract final class AppTypography {
  static const double display = 40;
  static const double title = 22;
  static const double body = 16;
  static const double label = 15;
  static const double caption = 13;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;
}

/// 间距尺度。
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 40;
  static const double page = 28;
}

/// 圆角尺度。
abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
}
