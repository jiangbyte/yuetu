import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/suggest_category.dart';
import '../../../data/repositories/providers.dart';
import '../../../domain/models/models.dart';

/// 新建/编辑笔记。
class NoteEditPage extends ConsumerStatefulWidget {
  const NoteEditPage({super.key, this.id});

  final String? id;

  @override
  ConsumerState<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends ConsumerState<NoteEditPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _category = '';
  List<String> _suggestions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final cats =
        await ref.read(categoryRepositoryProvider).listByType(CategoryKind.note);
    _suggestions = cats.map((c) => c.name).toList();
    if (widget.id != null) {
      final n = await ref.read(noteRepositoryProvider).get(widget.id!);
      if (n != null) {
        _titleCtrl.text = n.title;
        _contentCtrl.text = n.content;
        _category = n.category;
      }
    }
    if (_category.isEmpty && _suggestions.isNotEmpty) {
      _category = _suggestions.first;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写标题')),
      );
      return;
    }
    final cat =
        await ref.read(categoryRepositoryProvider).ensure(CategoryKind.note, _category);
    await ref.read(noteRepositoryProvider).save(
          id: widget.id,
          title: title,
          content: _contentCtrl.text,
          category: cat,
        );
    if (mounted) context.pop(true);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppPageHeader(
        title: widget.id == null ? '写笔记' : '编辑笔记',
        showBack: true,
        trailing: TextButton(onPressed: _save, child: const Text('保存')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(hintText: '标题'),
                ),
                const SizedBox(height: 16),
                SuggestCategory(
                  value: _category,
                  suggestions: _suggestions,
                  onChanged: (v) => setState(() => _category = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentCtrl,
                  maxLines: 12,
                  decoration: const InputDecoration(hintText: '正文'),
                ),
              ],
            ),
    );
  }
}
