import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_fab.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_text.dart';
import '../application/memorial_provider.dart';
import '../domain/memorial_item.dart';

/// 倒数纪念日列表页。
class MemorialPage extends ConsumerStatefulWidget {
  const MemorialPage({super.key});

  @override
  ConsumerState<MemorialPage> createState() => _MemorialPageState();
}

class _MemorialPageState extends ConsumerState<MemorialPage>
    with SingleTickerProviderStateMixin {
  bool _fabOpen = false;
  late final AnimationController _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() => _fabOpen = !_fabOpen);
    if (_fabOpen) {
      _fabAnim.forward();
    } else {
      _fabAnim.reverse();
    }
  }

  void _closeFab() {
    if (!_fabOpen) return;
    setState(() => _fabOpen = false);
    _fabAnim.reverse();
  }

  /// 打开添加页，带上预设类型。
  void _add(MemorialType type) {
    _closeFab();
    context.push('/memorial/edit?type=${type.name}');
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(memorialProvider);
    final fabBottom = AppFab.clearanceOf(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppPageHeader(
                title: '倒数纪念日',
                actions: [
                  AppIcon(LucideIcons.ellipsisVertical, size: 22),
                ],
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.only(bottom: fabBottom + 72),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final m = items[i];
                    return _MemorialCard(
                      item: m,
                      onTap: () => context.push('/memorial/${m.id}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (_fabOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeFab,
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ),
          ),
        Positioned(
          right: AppSpacing.page,
          bottom: fabBottom,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizeTransition(
                sizeFactor: _fabAnim,
                axis: Axis.vertical,
                alignment: Alignment.bottomCenter,
                child: FadeTransition(
                  opacity: _fabAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final t in MemorialType.values.reversed) ...[
                        _SpeedItem(
                          type: t,
                          onTap: () => _add(t),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  ),
                ),
              ),
              AppFab(onPressed: _toggleFab),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpeedItem extends StatelessWidget {
  const _SpeedItem({required this.type, required this.onTap});

  final MemorialType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(type.label, role: AppTextRole.label),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: AppIcon(type.icon, size: 22, color: type.color),
          ),
        ],
      ),
    );
  }
}

class _MemorialCard extends StatelessWidget {
  const _MemorialCard({required this.item, required this.onTap});

  final MemorialItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = item.isPast ? AppColors.checkin : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.type.iconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppIcon(
                item.type.icon,
                size: 24,
                color: item.type.color,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppText(item.name, role: AppTextRole.body),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  '${item.displayDays}',
                  role: AppTextRole.display,
                  color: accent,
                ),
                AppText(
                  item.statusLabel,
                  role: AppTextRole.caption,
                  color: accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
