import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/tokens.dart';

/// 圆形蓝底 FAB。
class AppFab extends StatelessWidget {
  const AppFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  /// Dock 内容区高度之上的基础间距。
  static const double dockClearance = 72;

  /// 含系统底 inset，避免 FAB 被 Dock / 手势条挡住。
  static double clearanceOf(BuildContext context) =>
      dockClearance + MediaQuery.paddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x334A7DFF),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(
          LucideIcons.plus,
          size: 28,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}
