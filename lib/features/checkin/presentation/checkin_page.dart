import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_fab.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_text.dart';
import '../application/habits_provider.dart';
import '../domain/habit_item.dart';

/// 习惯主页：周日期条 + 分组列表 / 空态。
class CheckInPage extends ConsumerWidget {
  const CheckInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitsProvider);
    final fabBottom = AppFab.clearanceOf(context);
    final day = state.selectedDay;
    final weekStart = day.subtract(Duration(days: day.weekday % 7));
    final grouped = state.grouped;
    final empty = state.habits.isEmpty;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: '习惯',
                actions: const [
                  AppIcon(LucideIcons.pieChart, size: 22),
                  SizedBox(width: AppSpacing.md),
                  AppIcon(LucideIcons.notebook, size: 22),
                  SizedBox(width: AppSpacing.md),
                  AppIcon(LucideIcons.slidersHorizontal, size: 22),
                ],
              ),
              _WeekStrip(
                weekStart: weekStart,
                selected: day,
                onSelect: (d) =>
                    ref.read(habitsProvider.notifier).selectDay(d),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: empty
                    ? const AppEmptyState(
                        title: '你这一天没有习惯',
                        subtitle: '坚持让我们闪闪发光',
                      )
                    : ListView(
                        padding: EdgeInsets.only(bottom: fabBottom + 56),
                        children: [
                          for (final entry in grouped.entries) ...[
                            _GroupCard(
                              title: entry.key,
                              habits: entry.value,
                              selectedDay: day,
                              isChecked: (id) => state.isChecked(id, day),
                              onTap: (h) {
                                if (state.isChecked(h.id, day)) {
                                  context.push('/checkin/done/${h.id}');
                                } else {
                                  context.push('/checkin/slide/${h.id}');
                                }
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
        Positioned(
          right: AppSpacing.page,
          bottom: fabBottom,
          child: AppFab(
            onPressed: () => context.push('/checkin/library'),
          ),
        ),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.weekStart,
    required this.selected,
    required this.onSelect,
  });

  final DateTime weekStart;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  static const _week = ['日', '一', '二', '三', '四', '五', '六'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: _Day(
              date: weekStart.add(Duration(days: i)),
              selected: _same(weekStart.add(Duration(days: i)), selected),
              onTap: onSelect,
            ),
          ),
      ],
    );
  }

  static bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Day extends StatelessWidget {
  const _Day({
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(date),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          AppText(
            _WeekStrip._week[date.weekday % 7],
            role: AppTextRole.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : null,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppText(
              '${date.day}',
              role: AppTextRole.label,
              color: selected ? AppColors.onPrimary : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.title,
    required this.habits,
    required this.selectedDay,
    required this.isChecked,
    required this.onTap,
  });

  final String title;
  final List<HabitItem> habits;
  final DateTime selectedDay;
  final bool Function(String id) isChecked;
  final ValueChanged<HabitItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              AppText(title, role: AppTextRole.label),
              const Spacer(),
              AppText('${habits.length}', role: AppTextRole.caption),
              const AppIcon(
                LucideIcons.chevronDown,
                size: 16,
                color: AppColors.inkMuted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final h in habits)
            GestureDetector(
              onTap: () => onTap(h),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: h.iconBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: AppIcon(h.icon, size: 22, color: AppColors.ink),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppText(
                        h.name,
                        role: AppTextRole.body,
                        color: isChecked(h.id)
                            ? AppColors.inkMuted
                            : AppColors.ink,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText(
                          '${h.currentStreak}天',
                          role: AppTextRole.title,
                        ),
                        const AppText('共坚持', role: AppTextRole.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
