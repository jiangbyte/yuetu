import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import 'app_text.dart';

/// 自定义页面壳：背景 + SafeArea + 可选标题，不走 Scaffold/AppBar 默认结构。
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.footer,
  });

  final Widget body;
  final String? title;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    // 1. 画布背景：浅色渐变，避免纯平单色
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.canvas, AppColors.canvasDeep],
        ),
      ),
      child: SafeArea(
        // 2. 页面内边距与纵向分区：标题 / 内容 / 页脚
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.page,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                AppText(title!, role: AppTextRole.title),
                const SizedBox(height: AppSpacing.lg),
              ],
              Expanded(child: body),
              if (footer != null) ...[
                const SizedBox(height: AppSpacing.lg),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
