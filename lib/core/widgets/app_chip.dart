import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import 'app_text.dart';

/// 筛选 / 标签 pill。
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.chipIdle,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: selected ? AppColors.primarySoft : AppColors.stroke,
          ),
        ),
        child: AppText(
          label,
          role: AppTextRole.caption,
          color: selected ? AppColors.primary : AppColors.ink,
          weight: selected ? AppTypography.medium : AppTypography.regular,
        ),
      ),
    );
  }
}
