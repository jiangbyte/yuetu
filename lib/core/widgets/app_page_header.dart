import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import 'app_text.dart';

/// 页头：大标题 + 可选副标题与右侧操作。
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, role: AppTextRole.pageTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  AppText(subtitle!, role: AppTextRole.caption),
                ],
              ],
            ),
          ),
          if (actions != null) ...?actions,
        ],
      ),
    );
  }
}
