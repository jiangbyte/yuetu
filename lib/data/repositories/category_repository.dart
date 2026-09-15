import 'package:drift/drift.dart';

import '../../core/constants/domain_constants.dart';
import '../../core/utils/id.dart';
import '../../domain/models/models.dart';
import '../db/app_database.dart';

/// 分类仓储：CRUD、颜色映射与业务引用校验。
class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  Category _map(CategoryEntry row) => Category(
        id: row.id,
        type: CategoryKind.fromValue(row.type),
        name: row.name,
        color: row.color,
        sortOrder: row.sortOrder,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  Future<List<Category>> listByType(CategoryKind type) async {
    final rows = await (_db.select(_db.categories)
          ..where((t) => t.type.equals(type.value))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
    return rows.map(_map).toList();
  }

  Future<Map<String, String>> colorMap({CategoryKind? type}) async {
    final query = _db.select(_db.categories);
    if (type != null) {
      query.where((t) => t.type.equals(type.value));
    }
    final rows = await query.get();
    return {for (final r in rows) r.name: r.color};
  }

  Future<String> create({
    required CategoryKind type,
    required String name,
    String? color,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw Exception('分类名称不能为空');

    final exists = await (_db.select(_db.categories)
          ..where((t) => t.type.equals(type.value) & t.name.equals(trimmed)))
        .getSingleOrNull();
    if (exists != null) throw Exception('同类型下已有该分类');

    final maxRow = await _db.customSelect(
      'SELECT COALESCE(MAX(sort_order), -1) AS m FROM categories WHERE type = ?',
      variables: [Variable.withString(type.value)],
      readsFrom: {_db.categories},
    ).getSingle();
    final now = DateTime.now().toIso8601String();
    final id = createId();
    await _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            id: id,
            type: type.value,
            name: trimmed,
            color: color ?? colorForCategory(trimmed),
            sortOrder: Value(maxRow.read<int>('m') + 1),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  /// 写入时确保分类进入历史；已存在则直接返回名称。
  Future<String> ensure(CategoryKind type, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final exists = await (_db.select(_db.categories)
          ..where((t) => t.type.equals(type.value) & t.name.equals(trimmed)))
        .getSingleOrNull();
    if (exists != null) return trimmed;

    final maxRow = await _db.customSelect(
      'SELECT COALESCE(MAX(sort_order), -1) AS m FROM categories WHERE type = ?',
      variables: [Variable.withString(type.value)],
      readsFrom: {_db.categories},
    ).getSingle();
    final now = DateTime.now().toIso8601String();
    await _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            id: createId(),
            type: type.value,
            name: trimmed,
            color: colorForCategory(trimmed),
            sortOrder: Value(maxRow.read<int>('m') + 1),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return trimmed;
  }

  Future<void> update({
    required String id,
    required String name,
    required String color,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw Exception('分类名称不能为空');

    final row = await (_db.select(_db.categories)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) throw Exception('分类不存在');

    final clash = await (_db.select(_db.categories)
          ..where(
            (t) =>
                t.type.equals(row.type) &
                t.name.equals(trimmed) &
                t.id.isNotValue(id),
          ))
        .getSingleOrNull();
    if (clash != null) throw Exception('同类型下已有该分类');

    final now = DateTime.now().toIso8601String();
    await (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(trimmed),
        color: Value(color),
        updatedAt: Value(now),
      ),
    );

    if (trimmed != row.name) {
      if (row.type == 'expense' || row.type == 'income') {
        await (_db.update(_db.transactions)
              ..where(
                (t) => t.type.equals(row.type) & t.category.equals(row.name),
              ))
            .write(
          TransactionsCompanion(
            category: Value(trimmed),
            updatedAt: Value(now),
          ),
        );
      } else if (row.type == 'note') {
        await (_db.update(_db.notes)..where((t) => t.category.equals(row.name)))
            .write(
          NotesCompanion(
            category: Value(trimmed),
            updatedAt: Value(now),
          ),
        );
      } else if (row.type == 'task') {
        await (_db.update(_db.tasks)..where((t) => t.category.equals(row.name)))
            .write(
          TasksCompanion(
            category: Value(trimmed),
            updatedAt: Value(now),
          ),
        );
      }
    }
  }

  Future<void> remove(String id) async {
    final row = await (_db.select(_db.categories)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) throw Exception('分类不存在');

    final left = await _db.customSelect(
      'SELECT COUNT(1) AS c FROM categories WHERE type = ?',
      variables: [Variable.withString(row.type)],
      readsFrom: {_db.categories},
    ).getSingle();
    if (left.read<int>('c') <= 1) {
      throw Exception('至少保留一个分类');
    }

    if (row.type == 'expense' || row.type == 'income') {
      final used = await _db.customSelect(
        'SELECT COUNT(1) AS c FROM transactions WHERE type = ? AND category = ?',
        variables: [
          Variable.withString(row.type),
          Variable.withString(row.name),
        ],
        readsFrom: {_db.transactions},
      ).getSingle();
      final c = used.read<int>('c');
      if (c > 0) {
        throw Exception('仍有 $c 笔流水使用该分类，请先修改流水后再删');
      }
    } else if (row.type == 'note') {
      final used = await _db.customSelect(
        'SELECT COUNT(1) AS c FROM notes WHERE category = ?',
        variables: [Variable.withString(row.name)],
        readsFrom: {_db.notes},
      ).getSingle();
      final c = used.read<int>('c');
      if (c > 0) throw Exception('仍有 $c 篇笔记使用该分类');
    } else if (row.type == 'task') {
      final used = await _db.customSelect(
        'SELECT COUNT(1) AS c FROM tasks WHERE category = ?',
        variables: [Variable.withString(row.name)],
        readsFrom: {_db.tasks},
      ).getSingle();
      final c = used.read<int>('c');
      if (c > 0) throw Exception('仍有 $c 个任务使用该分类');
    }

    await (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();
  }
}
