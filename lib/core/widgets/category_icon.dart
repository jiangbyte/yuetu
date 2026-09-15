import 'package:flutter/material.dart';

import '../utils/color.dart';

/// 分类首字色块徽章。
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.name,
    required this.colorHex,
    this.size = 36,
  });

  final String name;
  final String colorHex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(colorHex);
    final label = name.isEmpty ? '?' : name.characters.first;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
