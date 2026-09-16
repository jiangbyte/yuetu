import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_fab.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_text.dart';
import '../application/notes_provider.dart';
import '../domain/note_item.dart';

/// 笔记列表：筛选芯片、同步提示、白底列表。
class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  String _filter = '全部笔记';
  var _showSyncBanner = true;

  static const _filters = ['全部笔记', '手写笔记', '速记', '默认笔记'];

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final filtered = notes.where((n) {
      switch (_filter) {
        case '全部笔记':
          return true;
        case '手写笔记':
          return false;
        case '速记':
          return n.type == NoteType.quick;
        case '默认笔记':
          return n.type == NoteType.rich && n.notebook == '默认笔记本';
        default:
          return true;
      }
    }).toList();

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: '笔记',
                subtitle: '${notes.length} 篇笔记',
                actions: const [
                  AppIcon(LucideIcons.search, color: AppColors.inkMuted),
                  SizedBox(width: AppSpacing.md),
                  AppIcon(
                    LucideIcons.ellipsisVertical,
                    color: AppColors.inkMuted,
                  ),
                ],
              ),
              // 1. 笔记本入口 + 分类筛选
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _NotebookBtn(onTap: () {}),
                    const SizedBox(width: AppSpacing.sm),
                    for (final f in _filters) ...[
                      _FilterChip(
                        label: f,
                        selected: _filter == f,
                        onTap: () => setState(() => _filter = f),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // 2. 同步提示横幅
              if (_showSyncBanner) ...[
                _SyncBanner(
                  onIgnore: () => setState(() => _showSyncBanner = false),
                  onEnable: () => setState(() => _showSyncBanner = false),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              // 3. 白底笔记列表
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: filtered.isEmpty
                      ? const Center(
                          child: AppText('暂无笔记', role: AppTextRole.caption),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(
                            bottom: AppFab.clearanceOf(context) + 8,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const ColoredBox(
                            color: AppColors.stroke,
                            child: SizedBox(height: 1, width: double.infinity),
                          ),
                          itemBuilder: (context, i) {
                            final n = filtered[i];
                            return _NoteTile(
                              note: n,
                              onTap: () =>
                                  context.push('/notes/edit/${n.id}'),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: AppSpacing.page,
          bottom: AppFab.clearanceOf(context),
          child: AppFab(
            onPressed: () {
              final id = ref.read(notesProvider.notifier).create();
              context.push('/notes/edit/$id');
            },
          ),
        ),
      ],
    );
  }
}

class _NotebookBtn extends StatelessWidget {
  const _NotebookBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.stroke),
        ),
        alignment: Alignment.center,
        child: const AppIcon(LucideIcons.book, size: 18),
      ),
    );
  }
}

/// 灰底选中的筛选芯片（对齐截图）。
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.chipSelected : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: selected ? AppColors.chipSelected : AppColors.stroke,
          ),
        ),
        child: AppText(
          label,
          role: AppTextRole.caption,
          color: AppColors.ink,
          weight: selected ? AppTypography.medium : AppTypography.regular,
        ),
      ),
    );
  }
}

class _SyncBanner extends StatelessWidget {
  const _SyncBanner({required this.onIgnore, required this.onEnable});

  final VoidCallback onIgnore;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.chipSelected,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          const AppIcon(
            LucideIcons.cloud,
            size: 18,
            color: AppColors.inkMuted,
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: AppText(
              '开启便签自动同步，保障便签数据安全',
              role: AppTextRole.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onIgnore,
            child: const AppText(
              '忽略',
              role: AppTextRole.caption,
              color: AppColors.expense,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: onEnable,
            child: const AppText(
              '开启',
              role: AppTextRole.caption,
              color: AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.onTap});

  final NoteItem note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date =
        '${note.updatedAt.year}/${note.updatedAt.month}/${note.updatedAt.day}';
    final title = note.title.trim().isEmpty ? '无标题' : note.title.trim();
    final preview = note.plainPreview.trim();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              title,
              role: AppTextRole.body,
              weight: AppTypography.bold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            AppText(
              preview.isEmpty ? date : '$date  $preview',
              role: AppTextRole.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
