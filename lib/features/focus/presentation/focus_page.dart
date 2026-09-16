import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../application/focus_provider.dart';

/// 番茄 / 正计时。
class FocusPage extends ConsumerWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(focusTimerProvider);
    final notifier = ref.read(focusTimerProvider.notifier);
    final display = state.mode == FocusMode.pomodoro
        ? _fmt(state.remaining)
        : _fmt(state.elapsed);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _Tab(
                label: '番茄计时',
                selected: state.mode == FocusMode.pomodoro,
                onTap: () => notifier.setMode(FocusMode.pomodoro),
              ),
              const SizedBox(width: AppSpacing.lg),
              _Tab(
                label: '正计时',
                selected: state.mode == FocusMode.stopwatch,
                onTap: () => notifier.setMode(FocusMode.stopwatch),
              ),
            ],
          ),
          const Spacer(),
          const AppText('专注 ›', role: AppTextRole.caption),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
            ),
            alignment: Alignment.center,
            child: AppText(display, role: AppTextRole.display),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: state.running ? '暂停' : '开始',
            expanded: true,
            onPressed: notifier.toggle,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:$m:$s';
    }
    return '$m:$s';
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AppText(
            label,
            role: AppTextRole.title,
            color: selected ? AppColors.primary : AppColors.inkMuted,
            weight: selected ? AppTypography.bold : AppTypography.regular,
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 28,
            color: selected ? AppColors.primary : const Color(0x00000000),
          ),
        ],
      ),
    );
  }
}
