import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/tokens.dart';
import 'app_icon.dart';
import 'app_text.dart';

/// 空态：主副文案。
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            alignment: Alignment.center,
            child: const AppIcon(
              LucideIcons.calendar,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppText(title, role: AppTextRole.title, textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppText(
              subtitle!,
              role: AppTextRole.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
