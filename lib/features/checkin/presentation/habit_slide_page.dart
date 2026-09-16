import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_text.dart';
import '../application/habits_provider.dart';

/// 打卡滑动页：滑动完成当日打卡。
class HabitSlidePage extends ConsumerStatefulWidget {
  const HabitSlidePage({super.key, required this.habitId});

  final String habitId;

  @override
  ConsumerState<HabitSlidePage> createState() => _HabitSlidePageState();
}

class _HabitSlidePageState extends ConsumerState<HabitSlidePage> {
  double _drag = 0;
  static const _trackWidth = 280.0;
  static const _thumb = 56.0;

  /// 完成打卡并进入成果页。
  void _complete() {
    // 1. 写入打卡
    ref.read(habitsProvider.notifier).checkIn(widget.habitId);
    // 2. 替换为完成页
    context.pushReplacement('/checkin/done/${widget.habitId}');
  }

  @override
  Widget build(BuildContext context) {
    final habit = ref.watch(habitsProvider).byId(widget.habitId);
    if (habit == null) {
      return const Material(
        color: Color(0xFF82D1C1),
        child: Center(child: AppText('习惯不存在', role: AppTextRole.body)),
      );
    }

    final maxDrag = _trackWidth - _thumb - 8;
    final progress = (_drag / maxDrag).clamp(0.0, 1.0);

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
                    onTap: () => context.pop(),
                    child: const AppIcon(
                      LucideIcons.arrowLeft,
                      size: 22,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const Spacer(),
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
              child: AppIcon(habit.icon, size: 72, color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppText(
              habit.name,
              role: AppTextRole.display,
              color: AppColors.onPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              habit.encourage,
              role: AppTextRole.body,
              color: AppColors.onPrimary.withValues(alpha: 0.85),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: _trackWidth,
                height: 64,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      width: _trackWidth,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5BB8A8),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: (1 - progress).clamp(0.2, 1),
                        child: const AppText(
                          '滑动打卡',
                          role: AppTextRole.label,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 4 + _drag,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (d) {
                          setState(() {
                            _drag = (_drag + d.delta.dx).clamp(0.0, maxDrag);
                          });
                        },
                        onHorizontalDragEnd: (_) {
                          if (_drag >= maxDrag * 0.85) {
                            _complete();
                          } else {
                            setState(() => _drag = 0);
                          }
                        },
                        child: Container(
                          width: _thumb,
                          height: _thumb,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const AppIcon(
                            LucideIcons.check,
                            size: 28,
                            color: Color(0xFF82D1C1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
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
