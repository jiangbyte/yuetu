import 'package:drift/drift.dart';

import '../../core/utils/date.dart';
import '../../core/utils/id.dart';
import '../../domain/models/models.dart';
import '../db/app_database.dart';

/// 任务仓储。
class TaskRepository {
  TaskRepository(this._db);

  final AppDatabase _db;

  TaskItem _map(TaskEntry row) => TaskItem(
        id: row.id,
        title: row.title,
        category: row.category,
        done: row.done,
        dueAt: row.dueAt,
        priority: TaskPriority.fromValue(row.priority),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  Future<List<TaskItem>> list() async {
    final rows = await _db.customSelect(
      '''
      SELECT id, title, category, done, due_at, priority, created_at, updated_at
      FROM tasks
      ORDER BY done ASC,
        CASE priority WHEN 'high' THEN 0 WHEN 'medium' THEN 1 ELSE 2 END,
        CASE WHEN due_at IS NULL THEN 1 ELSE 0 END,
        due_at ASC,
        updated_at DESC
      ''',
      readsFrom: {_db.tasks},
    ).get();
    return rows
        .map(
          (r) => TaskItem(
            id: r.read<String>('id'),
            title: r.read<String>('title'),
            category: r.read<String>('category'),
            done: r.read<int>('done'),
            dueAt: r.readNullable<String>('due_at'),
            priority: TaskPriority.fromValue(r.read<String>('priority')),
            createdAt: r.read<String>('created_at'),
            updatedAt: r.read<String>('updated_at'),
          ),
        )
        .toList();
  }

  Future<List<TaskItem>> listByDueDate(String date) async {
    final rows = await (_db.select(_db.tasks)
          ..where((t) => t.dueAt.equals(date)))
        .get();
    final mapped = rows.map(_map).toList();
    mapped.sort((a, b) {
      if (a.done != b.done) return a.done.compareTo(b.done);
      final pa = a.priority == TaskPriority.high
          ? 0
          : a.priority == TaskPriority.medium
              ? 1
              : 2;
      final pb = b.priority == TaskPriority.high
          ? 0
          : b.priority == TaskPriority.medium
              ? 1
              : 2;
      if (pa != pb) return pa.compareTo(pb);
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return mapped;
  }

  Future<Map<String, int>> dueMarksByMonth(String ym) async {
    final range = monthRange(ym);
    final rows = await _db.customSelect(
      '''
      SELECT due_at AS day, COUNT(1) AS cnt
      FROM tasks
      WHERE due_at IS NOT NULL AND due_at >= ? AND due_at <= ?
      GROUP BY due_at
      ''',
      variables: [Variable.withString(range.start), Variable.withString(range.end)],
      readsFrom: {_db.tasks},
    ).get();
    final map = <String, int>{};
    for (final row in rows) {
      map[row.read<String>('day')] = row.read<int>('cnt');
    }
    return map;
  }

  Future<TaskItem?> get(String id) async {
    final row = await (_db.select(_db.tasks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _map(row);
  }

  Future<String> save({
    String? id,
    required String title,
    String? category,
    int? done,
    String? dueAt,
    TaskPriority? priority,
  }) async {
    // 1. 生成/读取主键，补齐时间戳
    // 2. 已存在则更新字段（未传的保持原值）
    // 3. 新建则写入默认中优先级与可选截止日期
    final now = DateTime.now().toIso8601String();
    final taskId = id ?? createId();
    final existing = id == null
        ? null
        : await (_db.select(_db.tasks)..where((t) => t.id.equals(taskId)))
            .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(
          title: Value(title),
          category: Value(category ?? existing.category),
          done: Value(done ?? existing.done),
          dueAt: Value(dueAt ?? existing.dueAt),
          priority: Value(priority?.value ?? existing.priority),
          updatedAt: Value(now),
        ),
      );
    } else {
      await _db.into(_db.tasks).insert(
            TasksCompanion.insert(
              id: taskId,
              title: title,
              category: Value(category ?? ''),
              done: Value(done ?? 0),
              dueAt: Value(dueAt),
              priority: Value(priority?.value ?? 'medium'),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    return taskId;
  }

  Future<void> toggle(String id) async {
    final row = await (_db.select(_db.tasks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return;
    final now = DateTime.now().toIso8601String();
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        done: Value(row.done == 0 ? 1 : 0),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> remove(String id) async {
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearAll() async {
    await _db.delete(_db.tasks).go();
  }
}
