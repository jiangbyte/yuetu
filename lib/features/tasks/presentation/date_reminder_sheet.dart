import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text.dart';

/// 日期与提醒选择结果。
class DateReminderResult {
  const DateReminderResult({this.date});

  final DateTime? date;
}

/// 日期与提醒 Sheet：快捷项 + 月历 + 时间/提醒/重复占位。
class DateReminderSheet extends StatefulWidget {
  const DateReminderSheet({super.key, this.initial});

  final DateTime? initial;

  /// 弹出并返回所选日期；取消返回 `null`（未确认）。
  static Future<DateReminderResult?> show(
    BuildContext context, {
    DateTime? initial,
  }) {
    return showAppSheet<DateReminderResult>(
      context: context,
      builder: (_) => DateReminderSheet(initial: initial),
    );
  }

  @override
  State<DateReminderSheet> createState() => _DateReminderSheetState();
}

class _DateReminderSheetState extends State<DateReminderSheet> {
  late DateTime _month;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    // 1. 初始选中日；无则落到今天
    final now = DateTime.now();
    final seed = widget.initial ?? DateTime(now.year, now.month, now.day);
    _selected = widget.initial == null
        ? null
        : DateTime(seed.year, seed.month, seed.day);
    _month = DateTime(seed.year, seed.month);
  }

  /// 确认当前选择并关闭。
  void _confirm() {
    Navigator.pop(context, DateReminderResult(date: _selected));
  }

  /// 快捷选日并确认感更强：只更新选中。
  void _pickQuick(DateTime day) {
    setState(() {
      _selected = DateTime(day.year, day.month, day.day);
      _month = DateTime(day.year, day.month);
    });
  }

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  DateTime get _tomorrow => _today.add(const Duration(days: 1));

  /// 下一个周一（含今天是周一则取下下周）。
  DateTime get _nextMonday {
    // 1. weekday: Mon=1 … Sun=7
    final t = _today;
    final delta = (DateTime.monday - t.weekday + 7) % 7;
    final days = delta == 0 ? 7 : delta;
    return t.add(Duration(days: days));
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const AppIcon(
                  LucideIcons.x,
                  size: 22,
                  color: AppColors.inkMuted,
                ),
              ),
              const Spacer(),
              const AppText('日期', role: AppTextRole.label, color: AppColors.primary),
              const SizedBox(width: AppSpacing.lg),
              const AppText(
                '时间段',
                role: AppTextRole.label,
                color: AppColors.inkMuted,
              ),
              const Spacer(),
              GestureDetector(
                onTap: _confirm,
                child: const AppIcon(
                  LucideIcons.check,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Quick(
                icon: LucideIcons.calendar,
                label: '今天',
                onTap: () => _pickQuick(_today),
              ),
              _Quick(
                icon: LucideIcons.sunrise,
                label: '明天',
                onTap: () => _pickQuick(_tomorrow),
              ),
              _Quick(
                icon: LucideIcons.calendarDays,
                label: '下周一',
                onTap: () => _pickQuick(_nextMonday),
              ),
              _Quick(
                icon: LucideIcons.sun,
                label: '明天上午',
                onTap: () => _pickQuick(_tomorrow),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(
                  () => _month = DateTime(_month.year, _month.month - 1),
                ),
                child: const AppIcon(
                  LucideIcons.chevronLeft,
                  size: 20,
                  color: AppColors.inkMuted,
                ),
              ),
              Expanded(
                child: AppText(
                  '${_month.month}月',
                  role: AppTextRole.title,
                  textAlign: TextAlign.center,
                ),
              ),
              GestureDetector(
                onTap: () => setState(
                  () => _month = DateTime(_month.year, _month.month + 1),
                ),
                child: const AppIcon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _MonthGrid(
            month: _month,
            selected: _selected,
            onSelect: (d) => setState(() => _selected = d),
          ),
          const SizedBox(height: AppSpacing.md),
          const _MetaRow(icon: LucideIcons.clock, label: '时间', value: '无'),
          const _MetaRow(icon: LucideIcons.bell, label: '提醒', value: '无'),
          const _MetaRow(icon: LucideIcons.repeat, label: '重复', value: '无'),
        ],
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  const _Quick({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            alignment: Alignment.center,
            child: AppIcon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(label, role: AppTextRole.caption),
        ],
      ),
    );
  }
}

/// 月历网格：日〜六，选中日蓝底。
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  static const _week = ['日', '一', '二', '三', '四', '五', '六'];

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // 1. 周日为列首：DateTime.weekday 周一=1…周日=7 → 偏移 0…6
    final lead = first.weekday % 7;
    final cells = <Widget>[
      for (final w in _week)
        Center(
          child: AppText(w, role: AppTextRole.caption),
        ),
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (var d = 1; d <= daysInMonth; d++)
        _Day(
          day: d,
          selected: selected != null &&
              selected!.year == month.year &&
              selected!.month == month.month &&
              selected!.day == d,
          onTap: () => onSelect(DateTime(month.year, month.month, d)),
        ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: cells,
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final int day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : null,
          shape: BoxShape.circle,
        ),
        child: AppText(
          '$day',
          role: AppTextRole.body,
          color: selected ? AppColors.onPrimary : AppColors.ink,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          AppIcon(icon, size: 20, color: AppColors.inkMuted),
          const SizedBox(width: AppSpacing.md),
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
