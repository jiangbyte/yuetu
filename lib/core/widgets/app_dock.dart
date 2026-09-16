import 'package:flutter/material.dart';

import '../../features/shell/domain/dock_module.dart';
import '../theme/tokens.dart';
import 'app_icon.dart';
import 'app_text.dart';

/// 可配置底栏。
class AppDock extends StatelessWidget {
  const AppDock({
    super.key,
    required this.modules,
    required this.current,
    required this.onSelect,
  });

  final List<DockModule> modules;
  final DockModule current;
  final ValueChanged<DockModule> onSelect;

  /// 底栏内容区高度（不含系统 inset）。
  static const double contentHeight = 56;

  /// 底栏总占位（含系统手势/Home 区），供 Sheet / FAB 贴边避让。
  static double heightOf(BuildContext context) =>
      contentHeight + MediaQuery.paddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          height: contentHeight,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.stroke)),
          ),
          child: Row(
            children: [
              for (final module in modules)
                Expanded(
                  child: _DockItem(
                    module: module,
                    selected: module == current,
                    onTap: () => onSelect(module),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.module,
    required this.selected,
    required this.onTap,
  });

  final DockModule module;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.inkMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(module.icon, size: 22, color: color),
          const SizedBox(height: 2),
          AppText(module.label, role: AppTextRole.caption, color: color),
        ],
      ),
    );
  }
}
