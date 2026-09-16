import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_fab.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../shell/application/dock_provider.dart';
import '../application/tasks_provider.dart';
import '../domain/task_item.dart';
import 'add_group_dialog.dart';
import 'date_reminder_sheet.dart';
import 'task_edit_sheet.dart';

/// 任务收集箱页。
class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  bool _showDone = true;

  /// 是否处于长按多选模式。
  bool _selecting = false;

  /// 已选任务 id。
  final Set<String> _selected = {};

  /// 同步底栏显隐：多选时隐藏。
  void _syncDockVisible(bool selecting) {
    ref.read(dockVisibleProvider.notifier).state = !selecting;
  }

  /// 进入多选并选中首项。
  void _enterSelect(String id) {
    setState(() {
      _selecting = true;
      _selected
        ..clear()
        ..add(id);
    });
    _syncDockVisible(true);
  }

  /// 退出多选。
  void _exitSelect() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
    _syncDockVisible(false);
  }

  /// 切换某项选中态。
  void _toggleSelect(String id) {
    var stillSelecting = true;
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        // 1. 全部取消后退出多选
        if (_selected.isEmpty) {
          _selecting = false;
          stillSelecting = false;
        }
      } else {
        _selected.add(id);
      }
    });
    _syncDockVisible(stillSelecting && _selecting);
  }

  @override
  void deactivate() {
    // 离开页时恢复底栏，避免其它 Tab 仍无 Dock
    if (_selecting) {
      ref.read(dockVisibleProvider.notifier).state = true;
    }
    super.deactivate();
  }

  /// 卡片点击：多选态切换选中，否则打开编辑。
  void _onCardTap(TaskItem t) {
    if (_selecting) {
      _toggleSelect(t.id);
    } else {
      TaskEditSheet.show(context, taskId: t.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksProvider);
    final tasks = state.filtered;
    final active = tasks.where((t) => !t.done).toList();
    final done = tasks.where((t) => t.done).toList();
    final fabBottom = AppFab.clearanceOf(context);
    final batchInset = MediaQuery.paddingOf(context).bottom;
    final empty = tasks.isEmpty;
    final listBottom = _selecting ? batchInset + 72 : fabBottom + 56;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_selecting)
                _SelectHeader(
                  count: _selected.length,
                  onBack: _exitSelect,
                )
              else
                const AppPageHeader(title: '收集箱'),
              _GroupBar(
                groups: state.allGroups,
                selected: state.selectedGroup,
                onSelect: (g) {
                  if (_selecting) return;
                  ref.read(tasksProvider.notifier).selectGroup(g);
                },
                onAdd: () => _addGroup(context),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: empty
                    ? const AppEmptyState(
                        title: '没有任务',
                        subtitle: '点击 + 按钮即可添加',
                      )
                    : ListView(
                        children: [
                          for (final t in active) ...[
                            _TaskCard(
                              task: t,
                              selecting: _selecting,
                              selected: _selected.contains(t.id),
                              onToggleDone: () => ref
                                  .read(tasksProvider.notifier)
                                  .toggle(t.id),
                              onTap: () => _onCardTap(t),
                              onLongPress: () => _enterSelect(t.id),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          if (done.isNotEmpty) ...[
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showDone = !_showDone),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                child: Row(
                                  children: [
                                    const AppText(
                                      '已完成',
                                      role: AppTextRole.label,
                                    ),
                                    const Spacer(),
                                    AppText(
                                      '${done.length}',
                                      role: AppTextRole.caption,
                                    ),
                                    AppIcon(
                                      _showDone
                                          ? LucideIcons.chevronDown
                                          : LucideIcons.chevronRight,
                                      size: 16,
                                      color: AppColors.inkMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_showDone)
                              for (final t in done) ...[
                                _TaskCard(
                                  task: t,
                                  selecting: _selecting,
                                  selected: _selected.contains(t.id),
                                  onToggleDone: () => ref
                                      .read(tasksProvider.notifier)
                                      .toggle(t.id),
                                  onTap: () => _onCardTap(t),
                                  onLongPress: () => _enterSelect(t.id),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                          ],
                          SizedBox(height: listBottom),
                        ],
                      ),
              ),
            ],
          ),
        ),
        if (!_selecting)
          Positioned(
            right: AppSpacing.page,
            bottom: fabBottom,
            child: AppFab(onPressed: () => _addTask(context)),
          ),
        if (_selecting)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BatchBar(
              enabled: _selected.isNotEmpty,
              onDate: () => _batchDate(),
              onPriority: () => _batchPriority(),
              onMove: () => _batchMove(),
              onDelete: () => _batchDelete(),
              onMore: () {},
            ),
          ),
      ],
    );
  }

  /// 打开统一任务编辑视图（新建）。
  Future<void> _addTask(BuildContext context) async {
    await TaskEditSheet.show(context);
  }

  /// 弹出添加分组对话框。
  Future<void> _addGroup(BuildContext context) async {
    // 1. 弹出对话框拿分组名
    final name = await AddGroupDialog.show(context);
    // 2. 写入并自动选中；重名时轻提示
    if (!mounted || name == null) return;
    final ok = ref.read(tasksProvider.notifier).addGroup(name);
    if (!ok && mounted) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('分组已存在')),
      );
    }
  }

  /// 批量设日期。
  Future<void> _batchDate() async {
    if (_selected.isEmpty) return;
    final result = await DateReminderSheet.show(context);
    if (!mounted || result == null) return;
    ref.read(tasksProvider.notifier).setDueMany(_selected, result.date);
    _exitSelect();
  }

  /// 批量设优先级。
  Future<void> _batchPriority() async {
    if (_selected.isEmpty) return;
    final picked = await showModalBottomSheet<TaskPriority>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final p in TaskPriority.values.reversed)
                ListTile(
                  leading: AppIcon(
                    LucideIcons.flag,
                    size: 20,
                    color: _priorityColor(p),
                  ),
                  title: AppText(_priorityLabel(p), role: AppTextRole.body),
                  onTap: () => Navigator.pop(ctx, p),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
    if (!mounted || picked == null) return;
    ref.read(tasksProvider.notifier).setPriorityMany(_selected, picked);
    _exitSelect();
  }

  /// 批量移动分组。
  Future<void> _batchMove() async {
    if (_selected.isEmpty) return;
    final groups = ref.read(tasksProvider).allGroups;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: AppText('移动到', role: AppTextRole.title),
              ),
              for (final g in groups)
                ListTile(
                  title: AppText(g, role: AppTextRole.body),
                  onTap: () => Navigator.pop(ctx, g),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
    if (!mounted || picked == null) return;
    ref.read(tasksProvider.notifier).moveMany(_selected, picked);
    _exitSelect();
  }

  /// 批量删除。
  Future<void> _batchDelete() async {
    if (_selected.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('删除任务', role: AppTextRole.title),
        content: AppText(
          '确定删除选中的 ${_selected.length} 项？',
          role: AppTextRole.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const AppText('取消', role: AppTextRole.label),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const AppText(
              '删除',
              role: AppTextRole.label,
              color: AppColors.expense,
            ),
          ),
        ],
      ),
    );
    if (!mounted || ok != true) return;
    ref.read(tasksProvider.notifier).removeMany(_selected);
    _exitSelect();
  }
}

/// 多选顶栏：返回 +「选中 N 项」。
class _SelectHeader extends StatelessWidget {
  const _SelectHeader({required this.count, required this.onBack});

  final int count;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: AppIcon(LucideIcons.arrowLeft, size: 22),
            ),
          ),
          AppText('选中$count项', role: AppTextRole.pageTitle),
        ],
      ),
    );
  }
}

/// 分组芯片行：横向滚动 chips + 数量 + 末尾「+」。
class _GroupBar extends StatelessWidget {
  const _GroupBar({
    required this.groups,
    required this.selected,
    required this.onSelect,
    required this.onAdd,
  });

  final List<String> groups;
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: groups.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          // 1. 分组 chips
          if (index < groups.length) {
            final g = groups[index];
            return AppChip(
              label: g,
              selected: g == selected,
              onTap: () => onSelect(g),
            );
          }
          // 2. 添加分组
          return GestureDetector(
            onTap: onAdd,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: AppIcon(
                  LucideIcons.plus,
                  size: 20,
                  color: AppColors.inkMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 底部批量操作栏。
class _BatchBar extends StatelessWidget {
  const _BatchBar({
    required this.enabled,
    required this.onDate,
    required this.onPriority,
    required this.onMove,
    required this.onDelete,
    required this.onMore,
  });

  final bool enabled;
  final VoidCallback onDate;
  final VoidCallback onPriority;
  final VoidCallback onMove;
  final VoidCallback onDelete;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.ink : AppColors.inkMuted;
    return Material(
      color: const Color(0xFF3A3F47),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BatchIcon(
                icon: LucideIcons.calendar,
                onTap: enabled ? onDate : null,
              ),
              _BatchIcon(
                icon: LucideIcons.flag,
                onTap: enabled ? onPriority : null,
              ),
              _BatchIcon(
                icon: LucideIcons.folderInput,
                onTap: enabled ? onMove : null,
              ),
              _BatchIcon(
                icon: LucideIcons.trash2,
                onTap: enabled ? onDelete : null,
              ),
              _BatchIcon(
                icon: LucideIcons.ellipsisVertical,
                onTap: enabled ? onMore : null,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatchIcon extends StatelessWidget {
  const _BatchIcon({
    required this.icon,
    this.onTap,
    this.color = AppColors.onPrimary,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: AppIcon(
            icon,
            size: 22,
            color: onTap == null ? AppColors.inkMuted : color,
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.selecting,
    required this.selected,
    required this.onToggleDone,
    required this.onTap,
    required this.onLongPress,
  });

  final TaskItem task;
  final bool selecting;
  final bool selected;
  final VoidCallback onToggleDone;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final done = task.done;
    return GestureDetector(
      onLongPress: onLongPress,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            if (selecting)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.inkMuted,
                    width: 1.5,
                  ),
                  color: selected ? AppColors.primary : null,
                ),
                alignment: Alignment.center,
                child: selected
                    ? const AppIcon(
                        LucideIcons.check,
                        size: 14,
                        color: AppColors.onPrimary,
                      )
                    : null,
              )
            else
              GestureDetector(
                onTap: onToggleDone,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: done ? AppColors.primary : AppColors.inkMuted,
                      width: 1.5,
                    ),
                    color: done ? AppColors.primary : null,
                  ),
                  alignment: Alignment.center,
                  child: done
                      ? const AppIcon(
                          LucideIcons.check,
                          size: 14,
                          color: AppColors.onPrimary,
                        )
                      : null,
                ),
              ),
            const SizedBox(width: AppSpacing.md),
            if (task.priority != TaskPriority.none) ...[
              AppIcon(
                LucideIcons.flag,
                size: 14,
                color: _priorityColor(task.priority),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: AppText(
                task.title,
                role: AppTextRole.body,
                color: done ? AppColors.inkMuted : AppColors.ink,
              ),
            ),
            if (task.dueLabel != null)
              AppText(
                task.dueLabel!,
                role: AppTextRole.caption,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

Color _priorityColor(TaskPriority p) => switch (p) {
      TaskPriority.high => const Color(0xFFE53935),
      TaskPriority.medium => const Color(0xFFFB8C00),
      TaskPriority.low => AppColors.primary,
      TaskPriority.none => AppColors.inkMuted,
    };

String _priorityLabel(TaskPriority p) => switch (p) {
      TaskPriority.high => '高优先级',
      TaskPriority.medium => '中优先级',
      TaskPriority.low => '低优先级',
      TaskPriority.none => '无优先级',
    };
