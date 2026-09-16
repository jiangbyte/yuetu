import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import 'app_text.dart';

/// 打卡连续天数徽章。
class CheckInBadge extends StatelessWidget {
  const CheckInBadge({
    super.key,
    required this.streakDays,
    required this.checkedToday,
  });

  final int streakDays;
  final bool checkedToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: checkedToday ? const Color(0xFFE8F8EF) : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: AppText(
        checkedToday ? '已打卡 · $streakDays 天' : '连续 $streakDays 天',
        role: AppTextRole.caption,
        color: checkedToday ? AppColors.checkin : AppColors.primary,
        weight: AppTypography.medium,
      ),
    );
  }
}
