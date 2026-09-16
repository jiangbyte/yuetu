import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/note_item.dart';

String _plainDelta(String text) {
  return jsonEncode([
    {'insert': '$text\n'},
  ]);
}

class NotesNotifier extends StateNotifier<List<NoteItem>> {
  NotesNotifier()
      : super([
          NoteItem(
            id: 'n1',
            title: '视频系统（当前版本 v1.6.7-2）',
            type: NoteType.rich,
            notebook: '默认笔记本',
            deltaJson: _plainDelta('优化与维护记录……'),
            updatedAt: DateTime(2026, 8, 26, 18, 20),
            plainPreview: '优化与维护记录……',
          ),
          NoteItem(
            id: 'n2',
            title: '企业管理（当前版本 v1.1.0）',
            type: NoteType.rich,
            notebook: '默认笔记本',
            deltaJson: _plainDelta('补丁与发布说明……'),
            updatedAt: DateTime(2026, 8, 26, 10, 0),
            plainPreview: '补丁与发布说明……',
          ),
          NoteItem(
            id: 'n3',
            title: '速记：买菜清单',
            type: NoteType.quick,
            notebook: '速记',
            deltaJson: _plainDelta('番茄 鸡蛋 牛奶'),
            updatedAt: DateTime(2026, 9, 10, 9, 0),
            plainPreview: '番茄 鸡蛋 牛奶',
          ),
        ]);

  NoteItem? byId(String id) {
    for (final n in state) {
      if (n.id == id) return n;
    }
    return null;
  }

  String create({NoteType type = NoteType.rich}) {
    final id = 'n${DateTime.now().millisecondsSinceEpoch}';
    final note = NoteItem(
      id: id,
      title: '',
      type: type,
      notebook: type == NoteType.quick ? '速记' : '默认笔记本',
      deltaJson: _plainDelta(''),
      updatedAt: DateTime.now(),
    );
    state = [note, ...state];
    return id;
  }

  void save({
    required String id,
    required String title,
    required String deltaJson,
    required String plainPreview,
  }) {
    state = [
      for (final n in state)
        if (n.id == id)
          n.copyWith(
            title: title,
            deltaJson: deltaJson,
            plainPreview: plainPreview,
            updatedAt: DateTime.now(),
          )
        else
          n,
    ];
  }
}

final notesProvider =
    StateNotifierProvider<NotesNotifier, List<NoteItem>>((ref) {
  return NotesNotifier();
});
