import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import 'category_repository.dart';
import 'data_repository.dart';
import 'note_repository.dart';
import 'task_repository.dart';
import 'transaction_repository.dart';

/// 数据库单例。
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final transactionRepositoryProvider = Provider(
  (ref) => TransactionRepository(ref.watch(databaseProvider)),
);

final taskRepositoryProvider = Provider(
  (ref) => TaskRepository(ref.watch(databaseProvider)),
);

final noteRepositoryProvider = Provider(
  (ref) => NoteRepository(ref.watch(databaseProvider)),
);

final categoryRepositoryProvider = Provider(
  (ref) => CategoryRepository(ref.watch(databaseProvider)),
);

final dataRepositoryProvider = Provider(
  (ref) => DataRepository(ref.watch(databaseProvider)),
);
