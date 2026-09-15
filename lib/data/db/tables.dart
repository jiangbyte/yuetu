import 'package:drift/drift.dart';

/// 元信息键值表。
@DataClassName('MetaEntry')
class MetaEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  String get tableName => 'meta';

  @override
  Set<Column> get primaryKey => {key};
}

/// 流水表。
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get category => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get paymentMethod =>
      text().named('payment_method').withDefault(const Constant('微信'))();
  TextColumn get occurredAt => text().named('occurred_at')();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

/// 笔记表。
@DataClassName('NoteEntry')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant(''))();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

/// 任务表。
@DataClassName('TaskEntry')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get done => integer().withDefault(const Constant(0))();
  TextColumn get dueAt => text().named('due_at').nullable()();
  TextColumn get category => text().withDefault(const Constant(''))();
  TextColumn get priority =>
      text().withDefault(const Constant('medium'))();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

/// 分类表。
@DataClassName('CategoryEntry')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get color => text()();
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
