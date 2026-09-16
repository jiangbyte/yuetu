import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text.dart';

/// 「添加」面板：相册 / 拍摄 / 表格 / 文件 / 扫描文本。
class NoteAddSheet extends StatelessWidget {
  const NoteAddSheet({super.key, this.onPick});

  final void Function(String action)? onPick;

  @override
  Widget build(BuildContext context) {
    const items = [
      (LucideIcons.image, '相册'),
      (LucideIcons.camera, '拍摄'),
      (LucideIcons.table, '表格'),
      (LucideIcons.folder, '文件'),
      (LucideIcons.scan, '扫描文本'),
    ];

    return AppSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppText('添加', role: AppTextRole.title),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.chipSelected,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const AppIcon(
                    LucideIcons.x,
                    size: 16,
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < items.length; i++)
                _AddItem(
                  icon: items[i].$1,
                  label: items[i].$2,
                  badge: items[i].$2 == '文件',
                  onTap: () {
                    Navigator.pop(context);
                    onPick?.call(items[i].$2);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _AddItem extends StatelessWidget {
  const _AddItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  alignment: Alignment.center,
                  child: AppIcon(icon, size: 24),
                ),
                if (badge)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.expense,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(label, role: AppTextRole.caption),
          ],
        ),
      ),
    );
  }
}
