import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/domain_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/swipe_delete.dart';
import '../../../data/repositories/providers.dart';
import '../../../domain/models/models.dart';

/// 分类管理：收支 / 笔记 / 任务四类 CRUD。
class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<Category> _list = [];
  bool _loading = true;

  static const _kinds = [
    CategoryKind.expense,
    CategoryKind.income,
    CategoryKind.note,
    CategoryKind.task,
  ];

  static const _labels = ['支出', '收入', '笔记', '任务'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) _load();
    });
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await ref
        .read(categoryRepositoryProvider)
        .listByType(_kinds[_tabs.index]);
    if (mounted) {
      setState(() {
        _list = list;
        _loading = false;
      });
    }
  }

  Future<void> _showEditor({Category? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var color = existing?.color ?? categoryColorPalette.first;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existing == null ? '新建分类' : '编辑分类',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(hintText: '分类名称'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categoryColorPalette.map((c) {
                      final selected = c == color;
                      return GestureDetector(
                        onTap: () => setModal(() => color = c),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: hexToColor(c),
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(color: AppColors.text, width: 2)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentDeep,
                    ),
                    child: const Text('保存'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (ok != true) return;
    try {
      final repo = ref.read(categoryRepositoryProvider);
      if (existing == null) {
        await repo.create(
          type: _kinds[_tabs.index],
          name: nameCtrl.text,
          color: color,
        );
      } else {
        await repo.update(
          id: existing.id,
          name: nameCtrl.text,
          color: color,
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _remove(Category c) async {
    try {
      await ref.read(categoryRepositoryProvider).remove(c.id);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppPageHeader(
        title: '分类管理',
        showBack: true,
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showEditor(),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabs,
            labelColor: AppColors.accentDeep,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.accentDeep,
            tabs: [for (final l in _labels) Tab(text: l)],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _list.length,
                    itemBuilder: (context, i) {
                      final c = _list[i];
                      return SwipeDelete(
                        onDelete: () => _remove(c),
                        child: ListTile(
                          leading: CategoryIcon(name: c.name, colorHex: c.color),
                          title: Text(c.name),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showEditor(existing: c),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
