import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text.dart';
import '../application/tasks_provider.dart';
import '../domain/task_item.dart';
import 'date_reminder_sheet.dart';

/// 任务编辑 Sheet：新建与点击任务共用同一视图（无勾选器）。
class TaskEditSheet extends ConsumerStatefulWidget {
  /// 新建或编辑；新建关闭时若有标题则写入列表。
  static Future<void> show(
    BuildContext context, {
    String? taskId,
    DateTime? initialDueDate,
  }) {
    return showAppSheet<void>(
      context: context,
      // 新建需等键盘；编辑直接展示
      requireIme: taskId == null,
      builder: (_) => TaskEditSheet(
        taskId: taskId,
        initialDueDate: initialDueDate,
      ),
    );
  }

  /// 为空表示新建。
  final String? taskId;

  /// 新建时预填到期日（如从日历选中日进入）。
  final DateTime? initialDueDate;

  const TaskEditSheet({
    super.key,
    this.taskId,
    this.initialDueDate,
  });

  @override
  ConsumerState<TaskEditSheet> createState() => _TaskEditSheetState();
}

class _TaskEditSheetState extends ConsumerState<TaskEditSheet> {
  late final TextEditingController _title;
  late final TextEditingController _note;
  late final FocusNode _titleFocus;
  late final FocusNode _noteFocus;

  String _group = TaskGroup.ungrouped;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.none;
  var _hydrated = false;
  var _saved = false;

  /// 页内浮层：优先级 / 分组（避免弹路由抢焦点导致键盘收起）。
  _SheetPanel _panel = _SheetPanel.none;

  bool get _isCreate => widget.taskId == null;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _note = TextEditingController();
    _titleFocus = FocusNode();
    _noteFocus = FocusNode();
    // 1. 浮层打开期间若焦点被抢走，立刻夺回并重开输入法
    _titleFocus.addListener(_onFieldFocusChange);
    _noteFocus.addListener(_onFieldFocusChange);
    // 2. 标题变化时刷新提交按钮可用态
    _title.addListener(_onTitleChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 1. 仅首帧灌入：编辑读已有任务，新建用当前筛选分组
    if (_hydrated) return;
    _hydrated = true;
    final state = ref.read(tasksProvider);
    final existing =
        widget.taskId == null ? null : state.byId(widget.taskId!);
    _title.text = existing?.title ?? '';
    _note.text = existing?.note ?? '';
    _group = existing?.group ?? state.selectedGroup;
    _dueDate = existing?.dueDate ??
        (widget.taskId == null ? widget.initialDueDate : null);
    _priority = existing?.priority ?? TaskPriority.none;
  }

  @override
  void dispose() {
    _title.removeListener(_onTitleChanged);
    _titleFocus.removeListener(_onFieldFocusChange);
    _noteFocus.removeListener(_onFieldFocusChange);
    _title.dispose();
    _note.dispose();
    _titleFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  void _onTitleChanged() => setState(() {});

  /// 浮层打开时防止工具栏点击把输入焦点打丢。
  void _onFieldFocusChange() {
    if (_panel == _SheetPanel.none) return;
    if (_titleFocus.hasFocus || _noteFocus.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _panel == _SheetPanel.none) return;
      _keepIme();
    });
  }

  /// 保住当前输入焦点与键盘，不让工具栏点击把 IME 收掉。
  void _keepIme() {
    // 1. 优先恢复标题焦点，否则恢复描述
    final node = _noteFocus.hasFocus ? _noteFocus : _titleFocus;
    if (!node.hasFocus) node.requestFocus();
    // 2. 显式唤起输入法（部分机型仅 requestFocus 不够）
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  /// 工具栏点击：先保键盘，再开页内浮层。
  void _onChromeTap(VoidCallback action) {
    // 1. pointer 阶段后立即要回焦点
    _keepIme();
    // 2. 执行业务（切浮层等）
    action();
    // 3. 下一帧再保一次，挡住 FocusManager 的延迟失焦
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _keepIme();
    });
  }

  /// 编辑态：把当前字段写回 provider。
  void _commitFields() {
    if (_isCreate) return;
    final id = widget.taskId!;
    final title = _title.text.trim();
    if (title.isEmpty) return;
    ref.read(tasksProvider.notifier).patch(
          id,
          title: title,
          note: _note.text,
          group: _group,
          priority: _priority,
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
        );
  }

  /// 新建落库（仅一次）。
  void _persistCreate() {
    // 1. 空标题或已保存则跳过
    final title = _title.text.trim();
    if (title.isEmpty || _saved) return;
    // 2. 写入列表
    _saved = true;
    ref.read(tasksProvider.notifier).add(
          title,
          group: _group,
          dueDate: _dueDate,
          priority: _priority,
          note: _note.text,
        );
  }

  /// 提交完成编辑：落库并关闭。
  void _submit() {
    // 1. 无标题不可提交
    if (_title.text.trim().isEmpty) return;
    // 2. 新建写入 / 编辑写回
    if (_isCreate) {
      _persistCreate();
    } else {
      _commitFields();
    }
    // 3. 关闭编辑层
    Navigator.of(context).pop();
  }

  /// 打开日期与提醒（全屏选择后恢复键盘）。
  Future<void> _pickDate() async {
    _keepIme();
    final result = await DateReminderSheet.show(
      context,
      initial: _dueDate,
    );
    if (!mounted) return;
    if (result != null) {
      setState(() => _dueDate = result.date);
      _commitFields();
    }
    _keepIme();
  }

  /// 切换优先级浮层。
  void _togglePriorityPanel() {
    setState(() {
      _panel = _panel == _SheetPanel.priority
          ? _SheetPanel.none
          : _SheetPanel.priority;
    });
  }

  /// 切换分组浮层。
  void _toggleGroupPanel() {
    setState(() {
      _panel =
          _panel == _SheetPanel.group ? _SheetPanel.none : _SheetPanel.group;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dueLabel = _dueDate == null
        ? null
        : '${_dueDate!.year}年${_dueDate!.month}月${_dueDate!.day}日';
    final groups = ref.watch(tasksProvider).allGroups;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        // 1. 路由已弹出且为新建时落库
        if (didPop && _isCreate) _persistCreate();
      },
      child: AppSheet(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _KeepImeTap(
                      onTap: () => _onChromeTap(_toggleGroupPanel),
                      child: Row(
                        children: [
                          AppText(
                            _group,
                            role: AppTextRole.label,
                            color: AppColors.primary,
                          ),
                          const AppIcon(
                            LucideIcons.chevronsUpDown,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _KeepImeTap(
                      onTap: () => _onChromeTap(_togglePriorityPanel),
                      child: AppIcon(
                        LucideIcons.flag,
                        size: 22,
                        color: _priorityColor(_priority),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const AppIcon(
                      LucideIcons.ellipsisVertical,
                      size: 22,
                      color: AppColors.inkMuted,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _KeepImeTap(
                  onTap: () => _onChromeTap(_pickDate),
                  child: AppText(
                    dueLabel ?? '日期与提醒',
                    role: AppTextRole.caption,
                    color: dueLabel != null
                        ? AppColors.primary
                        : AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _title,
                  focusNode: _titleFocus,
                  autofocus: _isCreate,
                  // 点工具栏时不要默认失焦收键盘
                  onTapOutside: (_) {},
                  style: const TextStyle(
                    fontSize: AppTypography.title,
                    fontWeight: AppTypography.bold,
                    color: AppColors.ink,
                    backgroundColor: Color(0x00000000),
                  ),
                  cursorColor: AppColors.primary,
                  maxLines: null,
                  onChanged: (_) => _commitFields(),
                  decoration: const InputDecoration(
                    hintText: '准备做什么？',
                    hintStyle: TextStyle(
                      fontSize: AppTypography.title,
                      fontWeight: AppTypography.bold,
                      color: AppColors.inkMuted,
                      backgroundColor: Color(0x00000000),
                    ),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                TextField(
                  controller: _note,
                  focusNode: _noteFocus,
                  onTapOutside: (_) {},
                  style: const TextStyle(
                    fontSize: AppTypography.body,
                    color: AppColors.ink,
                    backgroundColor: Color(0x00000000),
                  ),
                  cursorColor: AppColors.primary,
                  maxLines: 3,
                  minLines: 1,
                  onChanged: (_) => _commitFields(),
                  decoration: const InputDecoration(
                    hintText: '描述',
                    hintStyle: TextStyle(
                      fontSize: AppTypography.body,
                      color: AppColors.inkMuted,
                      backgroundColor: Color(0x00000000),
                    ),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: AppSpacing.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    _KeepImeTap(
                      onTap: () => _onChromeTap(_pickDate),
                      child: const AppIcon(
                        LucideIcons.calendar,
                        size: 20,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _KeepImeTap(
                      onTap: () => _onChromeTap(_togglePriorityPanel),
                      child: AppIcon(
                        LucideIcons.flag,
                        size: 20,
                        color: _priorityColor(_priority),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    const AppIcon(
                      LucideIcons.tag,
                      size: 20,
                      color: AppColors.inkMuted,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _KeepImeTap(
                      onTap: () => _onChromeTap(_toggleGroupPanel),
                      child: const AppIcon(
                        LucideIcons.inbox,
                        size: 20,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    const AppIcon(
                      LucideIcons.ellipsis,
                      size: 20,
                      color: AppColors.inkMuted,
                    ),
                    const Spacer(),
                    _SubmitButton(
                      enabled: _title.text.trim().isNotEmpty,
                      onTap: _submit,
                    ),
                  ],
                ),
              ],
            ),
            if (_panel == _SheetPanel.priority)
              Positioned(
                right: 0,
                bottom: 48,
                child: _PriorityPanel(
                  current: _priority,
                  onPick: (p) {
                    _onChromeTap(() {
                      setState(() {
                        _priority = p;
                        _panel = _SheetPanel.none;
                      });
                      _commitFields();
                    });
                  },
                ),
              ),
            if (_panel == _SheetPanel.group)
              Positioned(
                left: 0,
                right: 0,
                bottom: 48,
                child: _GroupPanel(
                  groups: groups,
                  current: _group,
                  onPick: (g) {
                    _onChromeTap(() {
                      setState(() {
                        _group = g;
                        _panel = _SheetPanel.none;
                      });
                      _commitFields();
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _SheetPanel { none, priority, group }

/// 工具栏右侧：完成编辑的圆形发送按钮。
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.stroke,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: AppIcon(
          LucideIcons.send,
          size: 18,
          color: enabled ? AppColors.onPrimary : AppColors.inkMuted,
        ),
      ),
    );
  }
}

/// 点击时在 pointerDown 阶段就夺回焦点，尽量不让键盘闪收。
class _KeepImeTap extends StatelessWidget {
  const _KeepImeTap({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        // 1. 比 GestureDetector 更早：立刻重新 requestFocus + show IME
        final primary = FocusManager.instance.primaryFocus;
        primary?.requestFocus();
        SystemChannels.textInput.invokeMethod('TextInput.show');
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _PriorityPanel extends StatelessWidget {
  const _PriorityPanel({required this.current, required this.onPick});

  final TaskPriority current;
  final ValueChanged<TaskPriority> onPick;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(AppRadii.md),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final p in TaskPriority.values.reversed)
              _KeepImeTap(
                onTap: () => onPick(p),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        LucideIcons.flag,
                        size: 18,
                        color: _priorityColor(p),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppText(_priorityLabel(p), role: AppTextRole.body),
                      if (p == current) ...[
                        const SizedBox(width: AppSpacing.md),
                        const AppIcon(
                          LucideIcons.check,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupPanel extends StatelessWidget {
  const _GroupPanel({
    required this.groups,
    required this.current,
    required this.onPick,
  });

  final List<String> groups;
  final String current;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(AppRadii.md),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: AppText('移动到', role: AppTextRole.label),
            ),
            for (final g in groups)
              _KeepImeTap(
                onTap: () => onPick(g),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(g, role: AppTextRole.body),
                      ),
                      if (g == current)
                        const AppIcon(
                          LucideIcons.check,
                          size: 16,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
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
