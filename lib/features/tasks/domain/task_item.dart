/// 任务优先级。
enum TaskPriority {
  none,
  low,
  medium,
  high,
}

/// 任务条目（内存假数据）。
class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    this.dueDate,
    this.done = false,
    this.group = TaskGroup.ungrouped,
    this.priority = TaskPriority.none,
    this.note = '',
  });

  final String id;
  final String title;
  final DateTime? dueDate;
  final bool done;

  /// 所属分组名称。
  final String group;
  final TaskPriority priority;
  final String note;

  /// 列表展示用到期文案。
  String? get dueLabel {
    final d = dueDate;
    if (d == null) return null;
    return '${d.year}年${d.month}月${d.day}日';
  }

  TaskItem copyWith({
    bool? done,
    String? title,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? group,
    TaskPriority? priority,
    String? note,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      done: done ?? this.done,
      group: group ?? this.group,
      priority: priority ?? this.priority,
      note: note ?? this.note,
    );
  }
}

/// 内置分组名。
abstract final class TaskGroup {
  static const ungrouped = '未分组';
}
