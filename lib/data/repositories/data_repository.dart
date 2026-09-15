import 'dart:convert';

import '../db/app_database.dart';

/// 数据导出与清空。
class DataRepository {
  DataRepository(this._db);

  final AppDatabase _db;

  /// 导出流水、笔记、任务、分类与元信息为可序列化对象。
  Future<Map<String, dynamic>> exportBundle() async {
    // 1. 按表拉取全量，避免导出遗漏
    // 2. 附带导出时间，便于文件命名与回溯
    final transactions = await _db.select(_db.transactions).get();
    final notes = await _db.select(_db.notes).get();
    final tasks = await _db.select(_db.tasks).get();
    final categories = await _db.select(_db.categories).get();
    final meta = await _db.select(_db.metaEntries).get();

    return {
      'app': 'yuetu',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'transactions': transactions
          .map(
            (t) => {
              'id': t.id,
              'type': t.type,
              'amount': t.amount,
              'category': t.category,
              'note': t.note,
              'payment_method': t.paymentMethod,
              'occurred_at': t.occurredAt,
              'created_at': t.createdAt,
              'updated_at': t.updatedAt,
            },
          )
          .toList(),
      'notes': notes
          .map(
            (n) => {
              'id': n.id,
              'title': n.title,
              'content': n.content,
              'category': n.category,
              'created_at': n.createdAt,
              'updated_at': n.updatedAt,
            },
          )
          .toList(),
      'tasks': tasks
          .map(
            (t) => {
              'id': t.id,
              'title': t.title,
              'done': t.done,
              'due_at': t.dueAt,
              'category': t.category,
              'priority': t.priority,
              'created_at': t.createdAt,
              'updated_at': t.updatedAt,
            },
          )
          .toList(),
      'categories': categories
          .map(
            (c) => {
              'id': c.id,
              'type': c.type,
              'name': c.name,
              'color': c.color,
              'sort_order': c.sortOrder,
              'created_at': c.createdAt,
              'updated_at': c.updatedAt,
            },
          )
          .toList(),
      'meta': meta.map((m) => {'key': m.key, 'value': m.value}).toList(),
    };
  }

  Future<String> exportJson() async {
    final bundle = await exportBundle();
    return const JsonEncoder.withIndent('  ').convert(bundle);
  }

  /// 清空流水、笔记、任务（分类与元信息保留）。
  Future<void> clearUserContent() async {
    // 1. 事务内删除三类内容表，保证要么全清要么全保留
    // 2. 分类与 meta 不动，避免用户预设结构丢失
    await _db.transaction(() async {
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.notes).go();
      await _db.delete(_db.tasks).go();
    });
  }
}
