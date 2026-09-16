import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_text.dart';
import '../application/habits_provider.dart';
import '../domain/habit_item.dart';

/// 新建习惯：两步（名称图标 / 频率分组）后写入内存。
class HabitCreatePage extends ConsumerStatefulWidget {
  const HabitCreatePage({super.key});

  @override
  ConsumerState<HabitCreatePage> createState() => _HabitCreatePageState();
}

class _HabitCreatePageState extends ConsumerState<HabitCreatePage> {
  final _name = TextEditingController(text: '吃水果');
  final _encourage = TextEditingController(text: '饭后来点水果就更棒了');
  var _step = 0;
  var _iconIndex = 3;
  var _freqTab = 0;
  final _weekdays = <int>{0, 1, 2, 3, 4, 5, 6};
  var _group = '其他';
  var _autoLog = false;

  @override
  void dispose() {
    _name.dispose();
    _encourage.dispose();
    super.dispose();
  }

  void _shuffleEncourage() {
    const pool = [
      '饭后来点水果就更棒了',
      '坚持一点点，生活亮一点',
      '今天也要闪闪发光',
      '完成打卡，给自己点个赞',
    ];
    final i = (pool.indexOf(_encourage.text) + 1) % pool.length;
    setState(() => _encourage.text = pool[i]);
  }

  /// 保存习惯并回主页。
  void _save() {
    // 1. 校验名称
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final icon = HabitCatalog.icons[_iconIndex];
    final now = DateTime.now();
    // 2. 写入 provider
    ref.read(habitsProvider.notifier).add(
          HabitItem(
            id: 'h${now.millisecondsSinceEpoch}',
            name: name,
            encourage: _encourage.text.trim(),
            icon: icon.$1,
            iconBg: icon.$2,
            group: _group,
            frequency: HabitFrequency.daily,
            weekdays: _weekdays.toList()..sort(),
            startDate: DateTime(now.year, now.month, now.day),
          ),
        );
    // 3. 回习惯主页
    context.go('/checkin');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.canvas,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_step == 0) {
                        context.pop();
                      } else {
                        setState(() => _step = 0);
                      }
                    },
                    child: const AppIcon(LucideIcons.arrowLeft, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const AppText('新习惯', role: AppTextRole.pageTitle),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                children: [
                  if (_step == 0) ..._stepOne() else ..._stepTwo(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              child: AppButton(
                label: _step == 0 ? '下一步' : '保存',
                expanded: true,
                onPressed: () {
                  if (_step == 0) {
                    setState(() => _step = 1);
                  } else {
                    _save();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _stepOne() {
    final selected = HabitCatalog.icons[_iconIndex];
    return [
      _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('习惯名称', role: AppTextRole.caption),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _name,
              style: const TextStyle(
                fontSize: AppTypography.body,
                color: AppColors.ink,
                backgroundColor: Color(0x00000000),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('图标', role: AppTextRole.caption),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _IconBubble(
                  icon: selected.$1,
                  bg: selected.$2,
                  selected: true,
                  large: true,
                ),
                const SizedBox(width: AppSpacing.md),
                _IconBubble(
                  icon: LucideIcons.aLargeSmall,
                  bg: const Color(0xFFFFE4D6),
                  selected: false,
                  large: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: HabitCatalog.icons.length,
              itemBuilder: (context, i) {
                final e = HabitCatalog.icons[i];
                return GestureDetector(
                  onTap: () => setState(() => _iconIndex = i),
                  child: Stack(
                    children: [
                      _IconBubble(icon: e.$1, bg: e.$2, selected: false),
                      if (i == _iconIndex)
                        const Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              LucideIcons.check,
                              size: 10,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppText('鼓励语', role: AppTextRole.caption),
                const Spacer(),
                GestureDetector(
                  onTap: _shuffleEncourage,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const AppIcon(
                      LucideIcons.refreshCw,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _encourage,
              style: const TextStyle(
                fontSize: AppTypography.body,
                color: AppColors.ink,
                backgroundColor: Color(0x00000000),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _stepTwo() {
    const tabs = ['按天', '按周', '按时间间隔'];
    const days = ['日', '一', '二', '三', '四', '五', '六'];
    final start = DateTime.now();
    return [
      _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('频率', role: AppTextRole.caption),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                for (var i = 0; i < tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.lg),
                  GestureDetector(
                    onTap: () => setState(() => _freqTab = i),
                    child: Column(
                      children: [
                        AppText(
                          tabs[i],
                          role: AppTextRole.label,
                          color: _freqTab == i
                              ? AppColors.primary
                              : AppColors.inkMuted,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 28,
                          height: 2,
                          color: _freqTab == i
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 7; i++)
                  GestureDetector(
                    onTap: () => setState(() {
                      if (_weekdays.contains(i)) {
                        if (_weekdays.length > 1) _weekdays.remove(i);
                      } else {
                        _weekdays.add(i);
                      }
                    }),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _weekdays.contains(i)
                            ? AppColors.primary
                            : AppColors.canvas,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: AppText(
                        days[i],
                        role: AppTextRole.caption,
                        color: _weekdays.contains(i)
                            ? AppColors.onPrimary
                            : AppColors.ink,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _Card(
        child: Column(
          children: [
            _RowTile(label: '目标', value: '当天完成打卡'),
            _RowTile(
              label: '开始日期',
              value: '${start.month}月${start.day}日',
            ),
            const _RowTile(label: '坚持天数', value: '永远'),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppText('所属分组', role: AppTextRole.caption),
                const Spacer(),
                const AppIcon(
                  LucideIcons.plus,
                  size: 18,
                  color: AppColors.inkMuted,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              children: [
                for (final g in HabitCatalog.groups)
                  GestureDetector(
                    onTap: () => setState(() => _group = g),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: _group == g
                            ? AppColors.primary
                            : AppColors.canvas,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: AppText(
                        g,
                        role: AppTextRole.caption,
                        color: _group == g
                            ? AppColors.onPrimary
                            : AppColors.ink,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _Card(
        child: Row(
          children: [
            const AppText('提醒', role: AppTextRole.body),
            const Spacer(),
            const AppText(
              '+ 添加',
              role: AppTextRole.label,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _Card(
        child: Row(
          children: [
            const Expanded(
              child: AppText('自动弹出打卡日志', role: AppTextRole.body),
            ),
            Switch(
              value: _autoLog,
              activeThumbColor: AppColors.onPrimary,
              activeTrackColor: AppColors.primary,
              onChanged: (v) => setState(() => _autoLog = v),
            ),
          ],
        ),
      ),
    ];
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: child,
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.bg,
    required this.selected,
    this.large = false,
  });

  final IconData icon;
  final Color bg;
  final bool selected;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 52.0 : 40.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: selected
            ? Border.all(color: const Color(0xFF95DE64), width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: AppIcon(icon, size: large ? 26 : 20),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          AppText(label, role: AppTextRole.body),
          const Spacer(),
          AppText(value, role: AppTextRole.caption),
          const AppIcon(
            LucideIcons.chevronRight,
            size: 16,
            color: AppColors.inkMuted,
          ),
        ],
      ),
    );
  }
}
