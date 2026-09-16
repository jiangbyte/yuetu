/// 笔记类型。
enum NoteType { rich, quick }

/// 笔记（富文本 Delta JSON 存字符串）。
class NoteItem {
  const NoteItem({
    required this.id,
    required this.title,
    required this.type,
    required this.notebook,
    required this.deltaJson,
    required this.updatedAt,
    this.plainPreview = '',
  });

  final String id;
  final String title;
  final NoteType type;
  final String notebook;
  final String deltaJson;
  final DateTime updatedAt;
  final String plainPreview;

  NoteItem copyWith({
    String? title,
    String? deltaJson,
    DateTime? updatedAt,
    String? plainPreview,
    NoteType? type,
    String? notebook,
  }) {
    return NoteItem(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      notebook: notebook ?? this.notebook,
      deltaJson: deltaJson ?? this.deltaJson,
      updatedAt: updatedAt ?? this.updatedAt,
      plainPreview: plainPreview ?? this.plainPreview,
    );
  }
}
