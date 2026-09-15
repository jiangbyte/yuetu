import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/domain_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/primary_fab.dart';
import '../../../core/widgets/swipe_delete.dart';
import '../../../data/repositories/providers.dart';
import '../../../domain/models/models.dart';

enum WorkspaceMode { task, note }

/// 事项工作区：任务 / 笔记合一。
class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  WorkspaceMode _mode = WorkspaceMode.task;
  List<TaskItem> _tasks = [];
  List<Note> _notes = [];
  Map<String, String> _colors = {};
  String _keyword = '';
  String _tag = '全部';
  bool _loading = true;
  static const _pageSize = 20;
  int _visible = _pageSize;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final tasks = await ref.read(taskRepositoryProvider).list();
    final notes = await ref.read(noteRepositoryProvider).list();
    final colors = await ref.read(categoryRepositoryProvider).colorMap();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _notes = notes;
        _colors = colors;
        _loading = false;
        _visible = _pageSize;
      });
    }
  }

  List<String> get _chips {
    final fromData = _mode == WorkspaceMode.task
        ? _tasks.map((t) => t.category)
        : _notes.map((n) => n.category);
    return ['全部', ...{...fromData.where((c) => c.isNotEmpty)}];
  }

  List<TaskItem> get _filteredTasks {
    final kw = _keyword.trim().toLowerCase();
    return _tasks.where((t) {
      if (_tag != '全部' && t.category != _tag) return false;
      if (kw.isNotEmpty && !'${t.title}${t.category}'.toLowerCase().contains(kw)) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Note> get _filteredNotes {
    final kw = _keyword.trim().toLowerCase();
    return _notes.where((n) {
      if (_tag != '全部' && n.category != _tag) return false;
      if (kw.isNotEmpty &&
          !'${n.title}${n.content}${n.category}'.toLowerCase().contains(kw)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _mode == WorkspaceMode.task ? _filteredTasks : _filteredNotes;
    final shown = items.take(_visible).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const AppPageHeader(title: '事项'),
      floatingActionButton: PrimaryFab(
        onPressed: () async {
          final path =
              _mode == WorkspaceMode.task ? '/tasks/edit' : '/notes/edit';
          await context.push(path);
          _load();
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('任务'),
                  selected: _mode == WorkspaceMode.task,
                  onSelected: (_) => setState(() {
                    _mode = WorkspaceMode.task;
                    _tag = '全部';
                    _visible = _pageSize;
                  }),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('笔记'),
                  selected: _mode == WorkspaceMode.note,
                  onSelected: (_) => setState(() {
                    _mode = WorkspaceMode.note;
                    _tag = '全部';
                    _visible = _pageSize;
                  }),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() {
                _keyword = v;
                _visible = _pageSize;
              }),
              decoration: const InputDecoration(
                hintText: '搜索',
                prefixIcon: Icon(LucideIcons.search, size: 18),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _chips
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(c),
                        selected: _tag == c,
                        onSelected: (_) => setState(() {
                          _tag = c;
                          _visible = _pageSize;
                        }),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: shown.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Text(
                                  '暂无内容',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: shown.length + (items.length > _visible ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i == shown.length) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  setState(() => _visible += _pageSize);
                                });
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              if (_mode == WorkspaceMode.task) {
                                final t = shown[i] as TaskItem;
                                return SwipeDelete(
                                  onDelete: () async {
                                    await ref
                                        .read(taskRepositoryProvider)
                                        .remove(t.id);
                                    await _load();
                                  },
                                  child: _TaskTile(
                                    item: t,
                                    colorHex: _colors[t.category] ??
                                        colorForCategory(t.category),
                                    onToggle: () async {
                                      await ref
                                          .read(taskRepositoryProvider)
                                          .toggle(t.id);
                                      await _load();
                                    },
                                    onTap: () async {
                                      await context.push('/tasks/edit?id=${t.id}');
                                      _load();
                                    },
                                  ),
                                );
                              }
                              final n = shown[i] as Note;
                              return SwipeDelete(
                                onDelete: () async {
                                  await ref
                                      .read(noteRepositoryProvider)
                                      .remove(n.id);
                                  await _load();
                                },
                                child: ListTile(
                                  leading: CategoryIcon(
                                    name: n.category.isEmpty ? '笔' : n.category,
                                    colorHex: _colors[n.category] ??
                                        colorForCategory(n.category),
                                  ),
                                  title: Text(n.title),
                                  subtitle: Text(
                                    n.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () async {
                                    await context.push('/notes/edit?id=${n.id}');
                                    _load();
                                  },
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.item,
    required this.colorHex,
    required this.onToggle,
    required this.onTap,
  });

  final TaskItem item;
  final String colorHex;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          item.isDone ? Icons.check_circle : Icons.circle_outlined,
          color: item.isDone ? AppColors.accent : AppColors.mute,
        ),
        onPressed: onToggle,
      ),
      title: Text(
        item.title,
        style: TextStyle(
          decoration: item.isDone ? TextDecoration.lineThrough : null,
          color: item.isDone ? AppColors.textSecondary : AppColors.text,
        ),
      ),
      subtitle: Text(
        [
          if (item.category.isNotEmpty) item.category,
          if (item.dueAt != null) formatDateShort(item.dueAt!),
          item.priority.label,
        ].join(' · '),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: CategoryIcon(
        name: item.category.isEmpty ? '任' : item.category,
        colorHex: colorHex,
        size: 28,
      ),
      onTap: onTap,
    );
  }
}
