import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_text.dart';
import '../application/habits_provider.dart';

/// 打卡完成页：统计 + 晒成果（UI 框架）。
class HabitDonePage extends ConsumerWidget {
  const HabitDonePage({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = ref.watch(habitsProvider).byId(habitId);
    if (habit == null) {
      return const Material(
        color: Color(0xFF82D1C1),
        child: Center(child: AppText('习惯不存在', role: AppTextRole.body)),
      );
    }

    return Material(
      color: const Color(0xFF82D1C1),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/checkin'),
                    child: const AppIcon(
                      LucideIcons.arrowLeft,
                      size: 22,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.onPrimary.withValues(alpha: 0.7),
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: const AppText(
                      '已完成',
                      role: AppTextRole.caption,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const AppIcon(
                    LucideIcons.ellipsisVertical,
                    size: 22,
                    color: AppColors.onPrimary,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: habit.iconBg.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppIcon(habit.icon, size: 72),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppText(
              habit.name,
              role: AppTextRole.display,
              color: AppColors.onPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              habit.encourage,
              role: AppTextRole.body,
              color: AppColors.onPrimary.withValues(alpha: 0.85),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _Stat(value: '${habit.totalCheckIns}', label: '总打卡'),
                        _Stat(value: '${habit.bestStreak}', label: '最高连续'),
                        _Stat(value: '${habit.currentStreak}', label: '当前连续'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: '晒一晒成果',
                      expanded: true,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const AppIcon(
              LucideIcons.chevronUp,
              size: 20,
              color: AppColors.onPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          AppText(value, role: AppTextRole.display),
          AppText(label, role: AppTextRole.caption),
        ],
      ),
    );
  }
}
