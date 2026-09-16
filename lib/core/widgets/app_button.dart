import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import 'app_text.dart';

/// 自绘主按钮。
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    // 1. 按启用/按下态决定背景
    final background = !_enabled
        ? AppColors.stroke
        : _pressed
            ? AppColors.primaryPressed
            : AppColors.primary;

    final child = GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        alignment: Alignment.center,
        child: AppText(
          widget.label,
          role: AppTextRole.label,
          color: AppColors.onPrimary,
          textAlign: TextAlign.center,
        ),
      ),
    );

    return widget.expanded ? child : IntrinsicWidth(child: child);
  }
}
