import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/suggest_category.dart';
import '../../../data/repositories/providers.dart';
import '../../../domain/models/models.dart';

/// 新建/编辑任务。
class TaskEditPage extends ConsumerStatefulWidget {
  const TaskEditPage({super.key, this.id, this.initialDue});

  final String? id;
  final String? initialDue;

  @override
  ConsumerState<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends ConsumerState<TaskEditPage> {
  final _titleCtrl = TextEditingController();
  String _category = '';
  String? _dueAt;
  TaskPriority _priority = TaskPriority.medium;
  int _done = 0;
  List<String> _suggestions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _dueAt = widget.initialDue ?? todayDate();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final cats =
        await ref.read(categoryRepositoryProvider).listByType(CategoryKind.task);
    _suggestions = cats.map((c) => c.name).toList();
    if (widget.id != null) {
      final t = await ref.read(taskRepositoryProvider).get(widget.id!);
      if (t != null) {
        _titleCtrl.text = t.title;
        _category = t.category;
        _dueAt = t.dueAt;
        _priority = t.priority;
        _done = t.done;
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
        await ref.read(categoryRepositoryProvider).ensure(CategoryKind.task, _category);
    await ref.read(taskRepositoryProvider).save(
          id: widget.id,
          title: title,
          category: cat,
          dueAt: _dueAt,
          priority: _priority,
          done: _done,
        );
    if (mounted) context.pop(true);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppPageHeader(
        title: widget.id == null ? '新任务' : '编辑任务',
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
                  decoration: const InputDecoration(hintText: '任务标题'),
                ),
                const SizedBox(height: 16),
                SuggestCategory(
                  value: _category,
                  suggestions: _suggestions,
                  onChanged: (v) => setState(() => _category = v),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('截止日期'),
                  trailing: Text(_dueAt == null ? '无' : formatDateShort(_dueAt!)),
                  onTap: () async {
                    final initial = DateTime.tryParse(_dueAt ?? todayDate()) ??
                        DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _dueAt =
                            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                ),
                const Text('优先级', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: TaskPriority.values
                      .map(
                        (p) => ChoiceChip(
                          label: Text(p.label),
                          selected: _priority == p,
                          onSelected: (_) => setState(() => _priority = p),
                        ),
                      )
                      .toList(),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('已完成'),
                  value: _done != 0,
                  onChanged: (v) => setState(() => _done = v ? 1 : 0),
                ),
              ],
            ),
    );
  }
}
