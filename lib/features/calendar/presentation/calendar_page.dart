import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_fab.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../tasks/application/tasks_provider.dart';
import '../../tasks/domain/task_item.dart';
import '../../tasks/presentation/task_edit_sheet.dart';

/// 日历：默认周视图，下滑展开整月，上滑收起。
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _selected;
  late DateTime _month;

  /// true = 月视图；false = 周视图。
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
    _month = DateTime(now.year, now.month);
  }

  /// 是否同一天。
  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// 选中日所在周的周日。
  DateTime get _weekStart {
    final w = _selected.weekday % 7;
    return _selected.subtract(Duration(days: w));
  }

  /// 处理纵向拖动：下滑展开，上滑收起。
  void _onVerticalDragEnd(DragEndDetails details) {
    // 1. 取纵向速度；过弱则看位移方向由 child 内滚动决定，这里只认明确甩动
    final v = details.primaryVelocity ?? 0;
    if (v > 280) {
      setState(() => _expanded = true);
    } else if (v < -280) {
      setState(() => _expanded = false);
    }
  }

  /// 选中某日；跨月时同步月锚点。
  void _select(DateTime day) {
    setState(() {
      _selected = DateTime(day.year, day.month, day.day);
      _month = DateTime(day.year, day.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fabBottom = AppFab.clearanceOf(context);
    final allItems = ref.watch(tasksProvider).items;
    final dayTasks = allItems
        .where(
          (t) =>
              !t.done &&
              t.dueDate != null &&
              _sameDay(t.dueDate!, _selected),
        )
        .toList();
    // 有到期任务的日期，供周/月格子打点
    final dueDays = <DateTime>{
      for (final t in allItems)
        if (!t.done && t.dueDate != null)
          DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day),
    };

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: '${_month.month}月',
                actions: const [
                  AppIcon(LucideIcons.slidersHorizontal, size: 22),
                  SizedBox(width: AppSpacing.md),
                  AppIcon(LucideIcons.list, size: 22),
                  SizedBox(width: AppSpacing.md),
                  AppIcon(LucideIcons.ellipsisVertical, size: 22),
                ],
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragEnd: _onVerticalDragEnd,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? _MonthPanel(
                          month: _month,
                          selected: _selected,
                          dueDays: dueDays,
                          onSelect: _select,
                          onMonthChange: (m) => setState(() => _month = m),
                        )
                      : _WeekPanel(
                          weekStart: _weekStart,
                          selected: _selected,
                          dueDays: dueDays,
                          onSelect: _select,
                          onExpand: () => setState(() => _expanded = true),
                        ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragEnd: _onVerticalDragEnd,
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.stroke,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: dayTasks.isEmpty
                    ? const AppEmptyState(
                        title: '你这一天没有任务',
                        subtitle: '放松一下吧',
                      )
                    : ListView(
                        padding: EdgeInsets.only(bottom: fabBottom + 56),
                        children: [
                          _DayTaskCard(
                            sectionLabel: _daySectionLabel(_selected),
                            dueLabel: _relativeDueLabel(_selected),
                            tasks: dayTasks,
                            onToggle: (id) =>
                                ref.read(tasksProvider.notifier).toggle(id),
                            onOpen: (id) => TaskEditSheet.show(
                              context,
                              taskId: id,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
        Positioned(
          right: AppSpacing.page,
          bottom: fabBottom,
          child: AppFab(onPressed: () => _addTask(context)),
        ),
      ],
    );
  }

  /// 区块标题：今天 / 明天 / x月x日。
  String _daySectionLabel(DateTime day) {
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    if (_sameDay(day, t)) return '今天';
    if (_sameDay(day, t.add(const Duration(days: 1)))) return '明天';
    if (_sameDay(day, t.subtract(const Duration(days: 1)))) return '昨天';
    return '${day.month}月${day.day}日';
  }

  /// 行尾相对日期文案。
  String _relativeDueLabel(DateTime day) => _daySectionLabel(day);

  /// 打开新建，预填当前选中日为到期日。
  Future<void> _addTask(BuildContext context) async {
    await TaskEditSheet.show(context, initialDueDate: _selected);
  }
}

/// 选中日任务列表卡片：区块标题 + 勾选行列表。
class _DayTaskCard extends StatelessWidget {
  const _DayTaskCard({
    required this.sectionLabel,
    required this.dueLabel,
    required this.tasks,
    required this.onToggle,
    required this.onOpen,
  });

  final String sectionLabel;
  final String dueLabel;
  final List<TaskItem> tasks;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(sectionLabel, role: AppTextRole.label),
          const SizedBox(height: AppSpacing.sm),
          for (final t in tasks)
            GestureDetector(
              onTap: () => onOpen(t.id),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => onToggle(t.id),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppText(t.title, role: AppTextRole.body),
                    ),
                    AppText(
                      dueLabel,
                      role: AppTextRole.caption,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 周视图：星期标题 + 一行日期；下滑手势由外层处理。
class _WeekPanel extends StatelessWidget {
  const _WeekPanel({
    required this.weekStart,
    required this.selected,
    required this.dueDays,
    required this.onSelect,
    required this.onExpand,
  });

  final DateTime weekStart;
  final DateTime selected;
  final Set<DateTime> dueDays;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onExpand;

  static const _week = ['日', '一', '二', '三', '四', '五', '六'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (final w in _week)
              Expanded(
                child: Center(
                  child: AppText(w, role: AppTextRole.caption),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onVerticalDragUpdate: (d) {
            if (d.delta.dy > 6) onExpand();
          },
          child: Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: _DayCell(
                    date: weekStart.add(Duration(days: i)),
                    selected: _isSame(
                      weekStart.add(Duration(days: i)),
                      selected,
                    ),
                    inMonth: true,
                    compact: true,
                    hasTask: dueDays.contains(
                      weekStart.add(Duration(days: i)),
                    ),
                    onTap: onSelect,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static bool _isSame(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 月视图：完整网格，含邻月灰字与节假日标记。
class _MonthPanel extends StatelessWidget {
  const _MonthPanel({
    required this.month,
    required this.selected,
    required this.dueDays,
    required this.onSelect,
    required this.onMonthChange,
  });

  final DateTime month;
  final DateTime selected;
  final Set<DateTime> dueDays;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<DateTime> onMonthChange;

  static const _week = ['日', '一', '二', '三', '四', '五', '六'];

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final lead = first.weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // 1. 凑满整周行，便于固定高度与邻月展示
    final total = ((lead + daysInMonth + 6) ~/ 7) * 7;
    final days = <DateTime>[
      for (var i = 0; i < total; i++)
        first.subtract(Duration(days: lead)).add(Duration(days: i)),
    ];

    return Column(
      children: [
        Row(
          children: [
            for (final w in _week)
              Expanded(
                child: Center(
                  child: AppText(w, role: AppTextRole.caption),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var row = 0; row < days.length ~/ 7; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: _DayCell(
                      date: days[row * 7 + c],
                      selected: _isSame(days[row * 7 + c], selected),
                      inMonth: days[row * 7 + c].month == month.month,
                      compact: false,
                      hasTask: dueDays.contains(days[row * 7 + c]),
                      onTap: (d) {
                        // 1. 点邻月日期时切换月锚点
                        if (d.month != month.month) {
                          onMonthChange(DateTime(d.year, d.month));
                        }
                        onSelect(d);
                      },
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static bool _isSame(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.selected,
    required this.inMonth,
    required this.compact,
    required this.hasTask,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool inMonth;
  final bool compact;
  final bool hasTask;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final meta = _CalendarMeta.of(date);
    final dayColor = selected
        ? AppColors.onPrimary
        : inMonth
            ? AppColors.ink
            : AppColors.inkMuted;

    return GestureDetector(
      onTap: () => onTap(date),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: compact ? 48 : 58,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : null,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: AppText(
                    '${date.day}',
                    role: AppTextRole.label,
                    color: dayColor,
                  ),
                ),
                if (hasTask && !selected)
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (!compact && meta.holiday != null)
                  AppText(
                    meta.holiday!,
                    role: AppTextRole.caption,
                    color: const Color(0xFF00B42A),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            if (!compact && meta.badge != null)
              Positioned(
                top: 0,
                right: 4,
                child: Container(
                  width: 14,
                  height: 14,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: meta.badge == '休'
                        ? const Color(0xFF00B42A)
                        : const Color(0xFFF24822),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    meta.badge!,
                    style: const TextStyle(
                      fontSize: 8,
                      color: AppColors.onPrimary,
                      backgroundColor: Color(0x00000000),
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 演示用节假日/调休元数据（贴近 2026 中秋国庆）。
class _CalendarMeta {
  const _CalendarMeta({this.holiday, this.badge});

  final String? holiday;
  final String? badge;

  static _CalendarMeta of(DateTime d) {
    final key = '${d.year}-${d.month}-${d.day}';
    return _table[key] ?? const _CalendarMeta();
  }

  static final _table = <String, _CalendarMeta>{
    '2026-9-10': const _CalendarMeta(holiday: '教师节'),
    '2026-9-20': const _CalendarMeta(badge: '班'),
    '2026-9-25': const _CalendarMeta(holiday: '中秋节', badge: '休'),
    '2026-9-26': const _CalendarMeta(badge: '休'),
    '2026-9-27': const _CalendarMeta(badge: '休'),
    '2026-10-1': const _CalendarMeta(holiday: '国庆节', badge: '休'),
    '2026-10-2': const _CalendarMeta(badge: '休'),
    '2026-10-3': const _CalendarMeta(badge: '休'),
    '2026-10-4': const _CalendarMeta(badge: '休'),
    '2026-10-5': const _CalendarMeta(badge: '休'),
    '2026-10-6': const _CalendarMeta(badge: '休'),
    '2026-10-7': const _CalendarMeta(badge: '休'),
    '2026-10-10': const _CalendarMeta(badge: '班'),
  };
}
