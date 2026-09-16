import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_text.dart';
import '../application/memorial_provider.dart';

/// 纪念日详情：撕页日历风格展示。
class MemorialDetailPage extends ConsumerWidget {
  const MemorialDetailPage({super.key, required this.id});

  final String id;

  static const _week = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(memorialProvider.select(
      (list) {
        for (final m in list) {
          if (m.id == id) return m;
        }
        return null;
      },
    ));

    if (item == null) {
      return const Material(
        color: Color(0xFFE8F0FF),
        child: Center(child: AppText('不存在', role: AppTextRole.body)),
      );
    }

    final target = item.highlightDate;
    final weekLabel = _week[(target.weekday - 1) % 7];
    final dateLine =
        '${target.year}/${target.month.toString().padLeft(2, '0')}/${target.day.toString().padLeft(2, '0')} 周$weekLabel';
    final prefix = item.isPast ? '自 $dateLine 起已过' : '距离 $dateLine 还有';

    return Material(
      color: const Color(0xFFE8F0FF),
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
                    child: const AppIcon(LucideIcons.arrowLeft, size: 22),
                  ),
                  const Spacer(),
                  const AppIcon(LucideIcons.ellipsisVertical, size: 22),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A4A7DFF),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppRadii.lg),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (final _ in [0, 1])
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      child: Column(
                        children: [
                          AppText(
                            prefix,
                            role: AppTextRole.caption,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppText(
                            '${item.displayDays}',
                            role: AppTextRole.display,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppText(
                            item.name,
                            role: AppTextRole.title,
                            color: AppColors.primary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            children: [
                              const Spacer(),
                              const AppIcon(
                                LucideIcons.smile,
                                size: 18,
                                color: AppColors.inkMuted,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              const AppIcon(
                                LucideIcons.image,
                                size: 18,
                                color: AppColors.inkMuted,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Action(icon: LucideIcons.messageCircle, onTap: () {}),
                  _Action(icon: LucideIcons.shirt, onTap: () {}),
                  _Action(icon: LucideIcons.share2, onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.inkMuted),
        ),
        alignment: Alignment.center,
        child: AppIcon(icon, size: 22, color: AppColors.inkMuted),
      ),
    );
  }
}
