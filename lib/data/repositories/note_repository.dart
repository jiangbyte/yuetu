import 'package:drift/drift.dart';

import '../../core/utils/id.dart';
import '../../domain/models/models.dart';
import '../db/app_database.dart';

/// 笔记仓储。
class NoteRepository {
  NoteRepository(this._db);

  final AppDatabase _db;

  Note _map(NoteEntry row) => Note(
        id: row.id,
        title: row.title,
        content: row.content,
        category: row.category,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  Future<List<Note>> list() async {
    final rows = await (_db.select(_db.notes)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    return rows.map(_map).toList();
  }

  Future<Note?> get(String id) async {
    final row = await (_db.select(_db.notes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _map(row);
  }

  Future<String> save({
    String? id,
    required String title,
    required String content,
    String? category,
  }) async {
    final now = DateTime.now().toIso8601String();
    final noteId = id ?? createId();
    final cat = category ?? '';
    final existing = id == null
        ? null
        : await (_db.select(_db.notes)..where((t) => t.id.equals(noteId)))
            .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.notes)..where((t) => t.id.equals(noteId))).write(
        NotesCompanion(
          title: Value(title),
          content: Value(content),
          category: Value(cat),
          updatedAt: Value(now),
        ),
      );
    } else {
      await _db.into(_db.notes).insert(
            NotesCompanion.insert(
              id: noteId,
              title: title,
              content: Value(content),
              category: Value(cat),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    return noteId;
  }

  Future<void> remove(String id) async {
    await (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearAll() async {
    await _db.delete(_db.notes).go();
  }
}
