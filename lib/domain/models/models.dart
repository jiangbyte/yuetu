/// 领域模型：流水、笔记、任务、分类与报表聚合。
library;

enum TxType {
  income,
  expense;

  String get value => name;

  static TxType fromValue(String v) =>
      v == 'income' ? TxType.income : TxType.expense;
}

/// 分类所属业务域
enum CategoryKind {
  income,
  expense,
  note,
  task;

  String get value => name;

  static CategoryKind fromValue(String v) {
    switch (v) {
      case 'income':
        return CategoryKind.income;
      case 'expense':
        return CategoryKind.expense;
      case 'note':
        return CategoryKind.note;
      case 'task':
        return CategoryKind.task;
      default:
        return CategoryKind.expense;
    }
  }
}

enum TaskPriority {
  high,
  medium,
  low;

  String get value => name;

  String get label {
    switch (this) {
      case TaskPriority.high:
        return '高';
      case TaskPriority.medium:
        return '中';
      case TaskPriority.low:
        return '低';
    }
  }

  static TaskPriority fromValue(String? v) {
    switch (v) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }
}

class LedgerTransaction {
  const LedgerTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.paymentMethod,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final TxType type;
  final double amount;
  final String category;
  final String note;
  final String paymentMethod;
  final String occurredAt;
  final String createdAt;
  final String updatedAt;
}

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final String category;
  final String createdAt;
  final String updatedAt;
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.category,
    required this.done,
    required this.dueAt,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String category;
  final int done;
  final String? dueAt;
  final TaskPriority priority;
  final String createdAt;
  final String updatedAt;

  bool get isDone => done != 0;
}

class Category {
  const Category({
    required this.id,
    required this.type,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final CategoryKind type;
  final String name;
  final String color;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;
}

class MonthSummary {
  const MonthSummary({
    required this.income,
    required this.expense,
    required this.balance,
  });

  final double income;
  final double expense;
  final double balance;

  static const empty = MonthSummary(income: 0, expense: 0, balance: 0);
}

class CategoryAgg {
  const CategoryAgg({required this.category, required this.total});

  final String category;
  final double total;
}

class DayTrend {
  const DayTrend({
    required this.day,
    required this.income,
    required this.expense,
  });

  final String day;
  final double income;
  final double expense;
}

class DayMark {
  const DayMark({
    required this.income,
    required this.expense,
    required this.count,
  });

  final double income;
  final double expense;
  final int count;
}

class DayGroup {
  const DayGroup({required this.date, required this.items});

  final String date;
  final List<LedgerTransaction> items;
}
