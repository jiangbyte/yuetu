import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 左滑露出删除按钮。
class SwipeDelete extends StatelessWidget {
  const SwipeDelete({
    super.key,
    required this.child,
    required this.onDelete,
    this.confirm = true,
  });

  final Widget child;
  final Future<void> Function() onDelete;
  final bool confirm;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        if (!confirm) {
          await onDelete();
          return true;
        }
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('确认删除'),
            content: const Text('删除后不可恢复'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.expense),
                child: const Text('删除'),
              ),
            ],
          ),
        );
        if (ok == true) await onDelete();
        return ok == true;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.expense,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: child,
    );
  }
}
