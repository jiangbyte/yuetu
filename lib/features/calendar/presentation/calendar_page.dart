import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/domain_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../data/repositories/providers.dart';
import '../../../domain/models/models.dart';

/// 日历：月格圆点 + 当日流水与任务。
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  String _ym = currentYearMonth();
  String _selected = todayDate();
  Map<String, DayMark> _txMarks = {};
  Map<String, int> _taskMarks = {};
  List<LedgerTransaction> _dayTx = [];
  List<TaskItem> _dayTasks = [];
  Map<String, String> _colors = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final txRepo = ref.read(transactionRepositoryProvider);
    final taskRepo = ref.read(taskRepositoryProvider);
    final catRepo = ref.read(categoryRepositoryProvider);
    final results = await Future.wait([
      txRepo.dayMarksByMonth(_ym),
      taskRepo.dueMarksByMonth(_ym),
      txRepo.listByDate(_selected),
      taskRepo.listByDueDate(_selected),
      catRepo.colorMap(),
    ]);
    if (mounted) {
      setState(() {
        _txMarks = results[0] as Map<String, DayMark>;
        _taskMarks = results[1] as Map<String, int>;
        _dayTx = results[2] as List<LedgerTransaction>;
        _dayTasks = results[3] as List<TaskItem>;
        _colors = results[4] as Map<String, String>;
        _loading = false;
      });
    }
  }

  void _switchMonth(int delta) {
    final ym = shiftYearMonth(_ym, delta);
    setState(() {
      _ym = ym;
      _selected = defaultDayInMonth(ym);
    });
    _load();
  }

  void _selectDay(String date) {
    setState(() => _selected = date);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cells = buildMonthGrid(_ym);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppPageHeader(
        title: formatYearMonth(_ym),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _switchMonth(-1),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _switchMonth(1),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: ['日', '一', '二', '三', '四', '五', '六']
                          .map(
                            (w) => Expanded(
                              child: Center(
                                child: Text(
                                  w,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: cells.length,
                    itemBuilder: (context, i) {
                      final c = cells[i];
                      final selected = c.date == _selected;
                      final hasTx = _txMarks.containsKey(c.date);
                      final hasTask = (_taskMarks[c.date] ?? 0) > 0;
                      return GestureDetector(
                        onTap: c.inMonth ? () => _selectDay(c.date) : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accentSoft
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${c.day}',
                                style: TextStyle(
                                  color: c.inMonth
                                      ? (c.isToday
                                          ? AppColors.accentDeep
                                          : AppColors.text)
                                      : AppColors.mute,
                                  fontWeight: selected || c.isToday
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (hasTx)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.only(right: 2),
                                      decoration: const BoxDecoration(
                                        color: AppColors.expense,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  if (hasTask)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: AppColors.task,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatDayLabel(_selected),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await context.push('/ledger/edit?date=$_selected');
                            _load();
                          },
                          child: const Text('记一笔'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await context.push('/tasks/edit?date=$_selected');
                            _load();
                          },
                          child: const Text('加任务'),
                        ),
                      ],
                    ),
                  ),
                  if (_dayTx.isEmpty && _dayTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          '当日暂无内容',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ..._dayTx.map(
                    (t) => ListTile(
                      leading: CategoryIcon(
                        name: t.category,
                        colorHex: _colors[t.category] ?? colorForCategory(t.category),
                      ),
                      title: Text(t.category),
                      subtitle: Text(t.note.isEmpty ? t.paymentMethod : t.note),
                      trailing: AmountText(type: t.type.value, amount: t.amount),
                      onTap: () async {
                        await context.push('/ledger/edit?id=${t.id}');
                        _load();
                      },
                    ),
                  ),
                  ..._dayTasks.map(
                    (t) => ListTile(
                      leading: Icon(
                        t.isDone ? Icons.check_circle : Icons.circle_outlined,
                        color: t.isDone ? AppColors.accent : AppColors.mute,
                      ),
                      title: Text(t.title),
                      subtitle: Text(
                        '${t.category.isEmpty ? '' : '${t.category} · '}${t.priority.label}',
                      ),
                      onTap: () async {
                        await context.push('/tasks/edit?id=${t.id}');
                        _load();
                      },
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
