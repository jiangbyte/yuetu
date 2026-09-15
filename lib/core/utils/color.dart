import 'package:flutter/material.dart';

/// 将 #RRGGBB 转为 Color，可选透明度。
Color hexToColor(String hex, {double opacity = 1}) {
  var h = hex.replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  final value = int.parse(h, radix: 16);
  return Color(value).withValues(alpha: opacity);
}

Color hexToRgba(String hex, double alpha) => hexToColor(hex, opacity: alpha);
