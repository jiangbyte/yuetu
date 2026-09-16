import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_text.dart';

/// 关于页。
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const AppIcon(LucideIcons.chevronLeft, size: 26),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(child: AppPageHeader(title: '关于')),
            ],
          ),
          const AppText(AppConstants.appName, role: AppTextRole.display),
          const SizedBox(height: AppSpacing.sm),
          const AppText(AppConstants.appTagline, role: AppTextRole.body),
          const SizedBox(height: AppSpacing.lg),
          const AppText('版本 1.0.0 · UI 壳', role: AppTextRole.caption),
        ],
      ),
    );
  }
}
