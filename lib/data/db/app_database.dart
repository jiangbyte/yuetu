import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/domain_constants.dart';
import '../../core/utils/id.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// 本地 SQLite 数据库（schema 对齐现网 v5）。
@DriftDatabase(tables: [MetaEntries, Transactions, Notes, Tasks, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          // 1. 创建全部表
          // 2. 写入 meta 与默认分类种子
          await m.createAll();
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_tx_occurred ON transactions(occurred_at)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_tx_type ON transactions(type)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_tasks_done ON tasks(done)',
          );
          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_cat_type_name ON categories(type, name)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_cat_type_sort ON categories(type, sort_order)',
          );
          await into(metaEntries).insert(
            MetaEntriesCompanion.insert(key: 'schema_version', value: '5'),
          );
          await into(metaEntries).insert(
            MetaEntriesCompanion.insert(key: 'ledger_name', value: '月兔账本'),
          );
          await seedDefaultCategories();
        },
        onUpgrade: (m, from, to) async {
          // 全新 Flutter 安装无旧库；保留升级钩子以兼容开发期迭代
          if (from < 5) {
            await m.createAll();
          }
        },
      );

  /// 写入四类默认分类（幂等）。
  Future<void> seedDefaultCategories() async {
    await _seedKind('expense', expenseCategories);
    await _seedKind('income', incomeCategories);
    await _seedKind('note', noteCategories);
    await _seedKind('task', taskCategories);
  }

  Future<void> _seedKind(String type, List<String> names) async {
    final now = DateTime.now().toIso8601String();
    var order = 0;
    for (final name in names) {
      final exists = await (select(categories)
            ..where((t) => t.type.equals(type) & t.name.equals(name)))
          .getSingleOrNull();
      if (exists != null) {
        order++;
        continue;
      }
      await into(categories).insert(
        CategoriesCompanion.insert(
          id: createId(),
          type: type,
          name: name,
          color: colorForCategory(name),
          sortOrder: Value(order++),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'yuetu.db'));
    return NativeDatabase.createInBackground(file);
  });
}
