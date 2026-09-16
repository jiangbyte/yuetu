import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_text.dart';
import '../application/habits_provider.dart';
import '../domain/habit_item.dart';

/// 习惯库：分类 chips + 模板列表 + 自定义入口。
class HabitLibraryPage extends ConsumerStatefulWidget {
  const HabitLibraryPage({super.key});

  @override
  ConsumerState<HabitLibraryPage> createState() => _HabitLibraryPageState();
}

class _HabitLibraryPageState extends ConsumerState<HabitLibraryPage> {
  String _category = HabitCatalog.categories.first;

  @override
  Widget build(BuildContext context) {
    final list = HabitCatalog.templates
        .where((t) => _category == '推荐' || t.category == _category)
        .toList();

    return Material(
      color: AppColors.canvas,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    child: const AppIcon(LucideIcons.arrowLeft, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const AppText('习惯库', role: AppTextRole.pageTitle),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                scrollDirection: Axis.horizontal,
                itemCount: HabitCatalog.categories.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final c = HabitCatalog.categories[i];
                  return AppChip(
                    label: c,
                    selected: c == _category,
                    onTap: () => setState(() => _category = c),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSpacing.lg,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final t = list[i];
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: t.iconBg,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: AppIcon(t.icon, size: 24),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(t.name, role: AppTextRole.body),
                              AppText(t.desc, role: AppTextRole.caption),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // 1. 从模板加入习惯
                            ref
                                .read(habitsProvider.notifier)
                                .addFromTemplate(t);
                            // 2. 回主页
                            context.go('/checkin');
                          },
                          child: const AppIcon(
                            LucideIcons.plus,
                            size: 22,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              child: AppButton(
                label: '自定义习惯',
                expanded: true,
                onPressed: () => context.push('/checkin/create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
