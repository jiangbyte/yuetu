import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_theme.dart';

/// 底部 Dock：流水 / 日历 / ⊕扇形 / 事项 / 我的。
class AppDock extends StatefulWidget {
  const AppDock({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onQuickLedger,
    required this.onQuickTask,
    required this.onQuickNote,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onQuickLedger;
  final VoidCallback onQuickTask;
  final VoidCallback onQuickNote;

  @override
  State<AppDock> createState() => _AppDockState();
}

class _AppDockState extends State<AppDock> with SingleTickerProviderStateMixin {
  bool _fanOpen = false;

  void _toggleFan() => setState(() => _fanOpen = !_fanOpen);

  void _runAction(VoidCallback action) {
    setState(() => _fanOpen = false);
    action();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_fanOpen) ...[
          _FanActions(
            onLedger: () => _runAction(widget.onQuickLedger),
            onTask: () => _runAction(widget.onQuickTask),
            onNote: () => _runAction(widget.onQuickNote),
            onClose: _toggleFan,
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: const BoxDecoration(
            color: AppColors.sheet,
            boxShadow: [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, -1),
              ),
            ],
          ),
          padding: EdgeInsets.only(bottom: bottom > 0 ? bottom : 8, top: 6),
          child: Row(
            children: [
              _DockTab(
                icon: LucideIcons.wallet,
                label: '流水',
                active: widget.currentIndex == 0,
                onTap: () => widget.onTabSelected(0),
              ),
              _DockTab(
                icon: LucideIcons.calendar,
                label: '日历',
                active: widget.currentIndex == 1,
                onTap: () => widget.onTabSelected(1),
              ),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _toggleFan,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.accentDeep,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _fanOpen ? LucideIcons.x : LucideIcons.plus,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              _DockTab(
                icon: LucideIcons.listTodo,
                label: '事项',
                active: widget.currentIndex == 2,
                onTap: () => widget.onTabSelected(2),
              ),
              _DockTab(
                icon: LucideIcons.user,
                label: '我的',
                active: widget.currentIndex == 3,
                onTap: () => widget.onTabSelected(3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DockTab extends StatelessWidget {
  const _DockTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accentDeep : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FanActions extends StatelessWidget {
  const _FanActions({
    required this.onLedger,
    required this.onTask,
    required this.onNote,
    required this.onClose,
  });

  final VoidCallback onLedger;
  final VoidCallback onTask;
  final VoidCallback onNote;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _FanChip(
            label: '记一笔',
            icon: LucideIcons.wallet,
            color: AppColors.accentDeep,
            onTap: onLedger,
          ),
          _FanChip(
            label: '加个任务',
            icon: LucideIcons.listTodo,
            color: AppColors.task,
            onTap: onTask,
          ),
          _FanChip(
            label: '写笔记',
            icon: LucideIcons.fileText,
            color: AppColors.note,
            onTap: onNote,
          ),
        ],
      ),
    );
  }
}

class _FanChip extends StatelessWidget {
  const _FanChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sheet,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: const Color(0x14000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
