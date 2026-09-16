import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import 'app_text.dart';

/// 自绘主按钮：按压缩放 + 色变，不使用 ElevatedButton 等默认组件。
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    // 1. 按启用/按下态决定背景色
    final background = !_enabled
        ? AppColors.stroke
        : _pressed
            ? AppColors.accentPressed
            : AppColors.accent;

    // 2. GestureDetector 处理按下反馈与点击，外层用 AnimatedContainer 过渡
    return GestureDetector(
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
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..scaleByDouble(_pressed ? 0.98 : 1.0, _pressed ? 0.98 : 1.0,
              _pressed ? 0.98 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: AppText(
          widget.label,
          role: AppTextRole.label,
          color: AppColors.onAccent,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
