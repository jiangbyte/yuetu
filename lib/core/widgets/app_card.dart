import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// 白底圆角卡片。
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: child,
    );

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: content);
  }
}
