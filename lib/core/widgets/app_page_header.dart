import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// 自定义顶栏：返回时无栈则回流水 Tab。
class AppPageHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.trailing,
    this.onBack,
  });

  final String title;
  final bool showBack;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sheet,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              if (showBack)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: onBack ??
                      () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/ledger');
                        }
                      },
                )
              else
                const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  textAlign: showBack ? TextAlign.left : TextAlign.center,
                ),
              ),
              if (trailing != null) trailing! else const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}
