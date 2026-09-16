import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text.dart';

/// 「格式」面板：段落样式、加粗斜体、列表缩进、对齐与高亮。
class NoteFormatSheet extends StatelessWidget {
  const NoteFormatSheet({super.key, required this.controller});

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    final attrs = controller.getSelectionStyle().attributes;
    final header = attrs[Attribute.header.key]?.value;
    final selectedStyle = switch (header) {
      1 => '标题',
      2 => '副标题',
      3 => '小标题',
      _ => attrs.containsKey(Attribute.blockQuote.key) ? '注释' : '正文',
    };

    return AppSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppText('格式', role: AppTextRole.title),
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
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final s in ['标题', '副标题', '小标题', '正文', '注释']) ...[
                  _StyleChip(
                    label: s,
                    selected: selectedStyle == s,
                    onTap: () => _applyStyle(s),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _IconBtn(
                icon: LucideIcons.bold,
                onTap: () => controller.formatSelection(Attribute.bold),
              ),
              _IconBtn(
                icon: LucideIcons.italic,
                onTap: () => controller.formatSelection(Attribute.italic),
              ),
              _IconBtn(
                icon: LucideIcons.underline,
                onTap: () => controller.formatSelection(Attribute.underline),
              ),
              _IconBtn(
                icon: LucideIcons.strikethrough,
                onTap: () =>
                    controller.formatSelection(Attribute.strikeThrough),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText('16', role: AppTextRole.caption),
                    AppIcon(
                      LucideIcons.chevronDown,
                      size: 14,
                      color: AppColors.inkMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _IconBtn(
                icon: LucideIcons.list,
                onTap: () => controller.formatSelection(Attribute.ul),
              ),
              _IconBtn(
                icon: LucideIcons.listOrdered,
                onTap: () => controller.formatSelection(Attribute.ol),
              ),
              _IconBtn(
                icon: LucideIcons.listTodo,
                onTap: () => controller.formatSelection(Attribute.unchecked),
              ),
              _IconBtn(
                icon: LucideIcons.indentDecrease,
                onTap: () => controller.formatSelection(
                  Attribute.clone(Attribute.indent, null),
                ),
              ),
              _IconBtn(
                icon: LucideIcons.indentIncrease,
                onTap: () => controller.formatSelection(Attribute.indentL1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _IconBtn(
                icon: LucideIcons.alignLeft,
                onTap: () =>
                    controller.formatSelection(Attribute.leftAlignment),
              ),
              _IconBtn(
                icon: LucideIcons.alignCenter,
                onTap: () =>
                    controller.formatSelection(Attribute.centerAlignment),
              ),
              _IconBtn(
                icon: LucideIcons.alignRight,
                onTap: () =>
                    controller.formatSelection(Attribute.rightAlignment),
              ),
              _IconBtn(
                icon: LucideIcons.highlighter,
                onTap: () => controller.formatSelection(
                  Attribute.fromKeyValue('background', '#FFF59D'),
                ),
              ),
              GestureDetector(
                onTap: () => controller.formatSelection(
                  Attribute.fromKeyValue('color', '#F24822'),
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.expense,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  void _applyStyle(String style) {
    switch (style) {
      case '标题':
        controller.formatSelection(Attribute.h1);
      case '副标题':
        controller.formatSelection(Attribute.h2);
      case '小标题':
        controller.formatSelection(Attribute.h3);
      case '注释':
        controller.formatSelection(Attribute.blockQuote);
      default:
        controller.formatSelection(Attribute.clone(Attribute.header, null));
    }
  }
}

class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.canvas,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: AppText(
          label,
          role: AppTextRole.caption,
          color: selected ? AppColors.onPrimary : AppColors.ink,
          weight: selected ? AppTypography.medium : AppTypography.regular,
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        alignment: Alignment.center,
        child: AppIcon(icon, size: 18),
      ),
    );
  }
}
