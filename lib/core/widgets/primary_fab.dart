import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 主色悬浮添加按钮。
class PrimaryFab extends StatelessWidget {
  const PrimaryFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.accentDeep,
      foregroundColor: Colors.white,
      elevation: 2,
      child: const Icon(Icons.add),
    );
  }
}
