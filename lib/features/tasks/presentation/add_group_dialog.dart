import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_text.dart';

/// 添加分组对话框：标题 + 名称输入 + 取消/确定。
class AddGroupDialog extends StatefulWidget {
  const AddGroupDialog({super.key});

  /// 弹出对话框，确认后返回分组名；取消返回 `null`。
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const AddGroupDialog(),
    );
  }

  @override
  State<AddGroupDialog> createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends State<AddGroupDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 1. 自持控制器，并监听文本以刷新「确定」可用性
    _controller = TextEditingController()..addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  /// 确认：有内容才带回名称。
  void _confirm() {
    // 1. 修剪输入
    final text = _controller.text.trim();
    // 2. 空内容不关闭；有内容则 pop 结果
    if (text.isEmpty) return;
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _controller.text.trim().isNotEmpty;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppText('添加分组', role: AppTextRole.title),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _confirm(),
              style: const TextStyle(
                fontSize: AppTypography.body,
                color: AppColors.ink,
                backgroundColor: Color(0x00000000),
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: '分组名称',
                hintStyle: const TextStyle(
                  fontSize: AppTypography.body,
                  color: AppColors.inkMuted,
                  backgroundColor: Color(0x00000000),
                ),
                filled: true,
                fillColor: AppColors.canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const AppText(
                    '取消',
                    role: AppTextRole.label,
                    color: AppColors.primary,
                  ),
                ),
                TextButton(
                  onPressed: canConfirm ? _confirm : null,
                  child: AppText(
                    '确定',
                    role: AppTextRole.label,
                    color: canConfirm
                        ? AppColors.primary
                        : AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
