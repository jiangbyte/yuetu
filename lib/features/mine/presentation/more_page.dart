import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/check_in_badge.dart';
import '../../checkin/application/habits_provider.dart';

/// 更多 / 我的。
class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: ListView(
        children: [
          const AppPageHeader(title: '更多'),
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const AppText('月', role: AppTextRole.title, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(AppConstants.appName, role: AppTextRole.title),
                      const SizedBox(height: 4),
                      CheckInBadge(
                        streakDays: habits.maxStreak == 0 ? 0 : habits.maxStreak,
                        checkedToday: habits.checkedToday,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Entry(
                  title: '笔记',
                  onTap: () => context.push('/notes'),
                ),
                _divider(),
                _Entry(
                  title: '习惯',
                  onTap: () => context.push('/checkin'),
                ),
                _divider(),
                _Entry(
                  title: '纪念日',
                  onTap: () => context.push('/memorial'),
                ),
                _divider(),
                _Entry(
                  title: '底栏设置',
                  onTap: () => context.push('/more/dock'),
                ),
                _divider(),
                _Entry(
                  title: '关于',
                  onTap: () => context.push('/about'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const ColoredBox(
        color: AppColors.stroke,
        child: SizedBox(height: 1, width: double.infinity),
      );
}

class _Entry extends StatelessWidget {
  const _Entry({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(child: AppText(title, role: AppTextRole.body)),
            const AppIcon(
              LucideIcons.chevronRight,
              size: 18,
              color: AppColors.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}
