import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/task_item.dart';

/// 收集箱：任务列表 + 自定义分组 + 当前选中分组。
class TasksState {
  const TasksState({
    required this.items,
    required this.groups,
    required this.selectedGroup,
  });

  final List<TaskItem> items;

  /// 用户自定义分组（不含「未分组」）。
  final List<String> groups;

  /// 当前筛选分组。
  final String selectedGroup;

  /// 侧栏/芯片展示的全部分组（未分组始终在首）。
  List<String> get allGroups => [TaskGroup.ungrouped, ...groups];

  /// 当前分组下的任务。
  List<TaskItem> get filtered =>
      items.where((t) => t.group == selectedGroup).toList();

  /// 按 id 查找任务。
  TaskItem? byId(String id) {
    for (final t in items) {
      if (t.id == id) return t;
    }
    return null;
  }

  TasksState copyWith({
    List<TaskItem>? items,
    List<String>? groups,
    String? selectedGroup,
  }) {
    return TasksState(
      items: items ?? this.items,
      groups: groups ?? this.groups,
      selectedGroup: selectedGroup ?? this.selectedGroup,
    );
  }
}

/// 收集箱状态变更。
class TasksNotifier extends StateNotifier<TasksState> {
  TasksNotifier()
      : super(
          TasksState(
            items: [
              TaskItem(
                id: 't1',
                title: '北上广深',
                dueDate: DateTime(2027, 6, 1),
              ),
              const TaskItem(id: 't2', title: '计算机网络实验报告'),
              const TaskItem(id: 't3', title: '整理月兔产品规格'),
              const TaskItem(id: 't4', title: '回顾本周账本', done: true),
              const TaskItem(id: 't5', title: '备份笔记草稿', done: true),
            ],
            groups: const [],
            selectedGroup: TaskGroup.ungrouped,
          ),
        );

  /// 切换完成态。
  void toggle(String id) {
    // 1. 按 id 翻转 done，其余条目原样保留
    state = state.copyWith(
      items: [
        for (final t in state.items)
          if (t.id == id) t.copyWith(done: !t.done) else t,
      ],
    );
  }

  /// 在当前分组下新增任务。
  void add(
    String title, {
    String? group,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.none,
    String note = '',
  }) {
    // 1. 空标题直接忽略
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    // 2. 写入当前选中分组（或显式指定分组）及可选元数据
    final g = group ?? state.selectedGroup;
    state = state.copyWith(
      items: [
        TaskItem(
          id: 't${DateTime.now().millisecondsSinceEpoch}',
          title: trimmed,
          group: g,
          dueDate: dueDate,
          priority: priority,
          note: note,
        ),
        ...state.items,
      ],
    );
  }

  /// 用完整条目替换同 id 任务。
  void update(TaskItem item) {
    // 1. 按 id 映射替换；无匹配则保持原列表
    final next = [
      for (final t in state.items)
        if (t.id == item.id) item else t,
    ];
    state = state.copyWith(items: next);
  }

  /// 按字段局部更新。
  void patch(
    String id, {
    String? title,
    bool? done,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? group,
    TaskPriority? priority,
    String? note,
  }) {
    // 1. 找到条目后 copyWith 写回
    state = state.copyWith(
      items: [
        for (final t in state.items)
          if (t.id == id)
            t.copyWith(
              title: title,
              done: done,
              dueDate: dueDate,
              clearDueDate: clearDueDate,
              group: group,
              priority: priority,
              note: note,
            )
          else
            t,
      ],
    );
  }

  /// 批量删除。
  void removeMany(Iterable<String> ids) {
    // 1. 空集合直接返回
    final idSet = ids.toSet();
    if (idSet.isEmpty) return;
    // 2. 过滤掉命中 id
    state = state.copyWith(
      items: [for (final t in state.items) if (!idSet.contains(t.id)) t],
    );
  }

  /// 批量移动到指定分组。
  void moveMany(Iterable<String> ids, String group) {
    // 1. 校验分组合法
    if (!state.allGroups.contains(group)) return;
    final idSet = ids.toSet();
    if (idSet.isEmpty) return;
    // 2. 命中条目改分组
    state = state.copyWith(
      items: [
        for (final t in state.items)
          if (idSet.contains(t.id)) t.copyWith(group: group) else t,
      ],
    );
  }

  /// 批量设置到期日。
  void setDueMany(Iterable<String> ids, DateTime? dueDate) {
    final idSet = ids.toSet();
    if (idSet.isEmpty) return;
    state = state.copyWith(
      items: [
        for (final t in state.items)
          if (idSet.contains(t.id))
            t.copyWith(dueDate: dueDate, clearDueDate: dueDate == null)
          else
            t,
      ],
    );
  }

  /// 批量设置优先级。
  void setPriorityMany(Iterable<String> ids, TaskPriority priority) {
    final idSet = ids.toSet();
    if (idSet.isEmpty) return;
    state = state.copyWith(
      items: [
        for (final t in state.items)
          if (idSet.contains(t.id)) t.copyWith(priority: priority) else t,
      ],
    );
  }

  /// 选中分组用于筛选列表。
  void selectGroup(String group) {
    // 1. 非法分组名忽略，避免筛空
    if (!state.allGroups.contains(group)) return;
    state = state.copyWith(selectedGroup: group);
  }

  /// 新增自定义分组并自动选中。
  bool addGroup(String name) {
    // 1. 修剪并校验非空
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    // 2. 与「未分组」或已有分组重名则拒绝
    if (trimmed == TaskGroup.ungrouped || state.groups.contains(trimmed)) {
      return false;
    }
    // 3. 追加分组并切到新分组
    state = state.copyWith(
      groups: [...state.groups, trimmed],
      selectedGroup: trimmed,
    );
    return true;
  }
}

final tasksProvider =
    StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  return TasksNotifier();
});
