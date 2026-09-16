import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// 统一图标尺寸与颜色约定。
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size = 22,
    this.color,
  });

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color ?? AppColors.ink,
    );
  }
}
