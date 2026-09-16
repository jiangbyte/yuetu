import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../shell/application/dock_provider.dart';
import '../../shell/domain/dock_module.dart';

/// 底栏模块勾选与排序。
class DockSettingsPage extends ConsumerWidget {
  const DockSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dock = ref.watch(dockProvider);
    final notifier = ref.read(dockProvider.notifier);
    final selectable = DockModule.values
        .where((m) => m != DockModule.more)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: ListView(
        children: [
          const AppPageHeader(
            title: '底栏设置',
            subtitle: '最多 4 个模块，「更多」固定在末位',
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < selectable.length; i++) ...[
                  if (i > 0)
                    const ColoredBox(
                      color: AppColors.stroke,
                      child: SizedBox(height: 1, width: double.infinity),
                    ),
                  _Row(
                    module: selectable[i],
                    enabled: dock.contains(selectable[i]),
                    onToggle: () => notifier.toggle(selectable[i]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const AppText('当前顺序', role: AppTextRole.label),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < dock.length; i++) ...[
                  if (i > 0)
                    const ColoredBox(
                      color: AppColors.stroke,
                      child: SizedBox(height: 1, width: double.infinity),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        AppText(dock[i].label, role: AppTextRole.body),
                        const Spacer(),
                        if (dock[i] != DockModule.more) ...[
                          GestureDetector(
                            onTap: () => notifier.moveUp(i),
                            child: const AppIcon(LucideIcons.arrowUp, size: 18),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          GestureDetector(
                            onTap: () => notifier.moveDown(i),
                            child: const AppIcon(LucideIcons.arrowDown, size: 18),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.module,
    required this.enabled,
    required this.onToggle,
  });

  final DockModule module;
  final bool enabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(child: AppText(module.label, role: AppTextRole.body)),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: enabled ? AppColors.primary : null,
                border: Border.all(
                  color: enabled ? AppColors.primary : AppColors.inkMuted,
                ),
              ),
              alignment: Alignment.center,
              child: enabled
                  ? const AppIcon(
                      LucideIcons.check,
                      size: 14,
                      color: AppColors.onPrimary,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
