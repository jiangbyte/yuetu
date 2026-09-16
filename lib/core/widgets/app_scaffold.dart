import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// 页面壳：浅灰底 + SafeArea（必须包 Material，否则文字会出现黄双下划线）。
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.floatingActionButton,
    this.bottomBar,
    this.padding,
  });

  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomBar;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.canvas,
      child: Stack(
        children: [
          SafeArea(
            bottom: bottomBar == null,
            child: Padding(
              padding: padding ??
                  const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: body,
            ),
          ),
          if (floatingActionButton != null)
            Positioned(
              right: AppSpacing.page,
              bottom: (bottomBar != null ? 72 : 24) +
                  MediaQuery.paddingOf(context).bottom,
              child: floatingActionButton!,
            ),
          if (bottomBar != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: bottomBar!,
            ),
        ],
      ),
    );
  }
}
