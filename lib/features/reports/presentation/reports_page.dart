import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/domain_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color.dart';
import '../../../core/utils/date.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../data/repositories/providers.dart';
import '../../../domain/models/models.dart';

/// 报表：月支出分类饼图 + 日趋势。
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key, this.initialYm});

  final String? initialYm;

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  late String _ym;
  List<CategoryAgg> _agg = [];
  List<DayTrend> _trend = [];
  Map<String, String> _colors = {};
  MonthSummary _summary = MonthSummary.empty;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ym = widget.initialYm ?? currentYearMonth();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final tx = ref.read(transactionRepositoryProvider);
    final cat = ref.read(categoryRepositoryProvider);
    final results = await Future.wait([
      tx.categoryAgg(_ym),
      tx.dayTrend(_ym),
      tx.monthSummary(_ym),
      cat.colorMap(type: CategoryKind.expense),
    ]);
    if (mounted) {
      setState(() {
        _agg = results[0] as List<CategoryAgg>;
        _trend = results[1] as List<DayTrend>;
        _summary = results[2] as MonthSummary;
        _colors = results[3] as Map<String, String>;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppPageHeader(
        title: '报表 · ${formatYearMonth(_ym)}',
        showBack: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() => _ym = shiftYearMonth(_ym, -1));
                _load();
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() => _ym = shiftYearMonth(_ym, 1));
                _load();
              },
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.sheet,
                    borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '支出 ${formatMoney(_summary.expense)}',
                          style: const TextStyle(
                            color: AppColors.expense,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '收入 ${formatMoney(_summary.income)}',
                        style: const TextStyle(
                          color: AppColors.income,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('支出构成', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: _agg.isEmpty
                      ? const Center(
                          child: Text(
                            '本月暂无支出',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              for (var i = 0; i < _agg.length; i++)
                                PieChartSectionData(
                                  value: _agg[i].total,
                                  title: _agg[i].category,
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  color: hexToColor(
                                    _colors[_agg[i].category] ??
                                        colorForCategory(_agg[i].category),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                ..._agg.map(
                  (a) => ListTile(
                    dense: true,
                    leading: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: hexToColor(
                          _colors[a.category] ?? colorForCategory(a.category),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(a.category),
                    trailing: Text(formatMoney(a.total)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('每日趋势', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: _trend.isEmpty
                      ? const Center(
                          child: Text(
                            '暂无数据',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, meta) {
                                    final i = v.toInt();
                                    if (i < 0 || i >= _trend.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final day = _trend[i].day.split('-').last;
                                    return Text(
                                      day,
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              for (var i = 0; i < _trend.length; i++)
                                BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: _trend[i].expense,
                                      color: AppColors.expense,
                                      width: 6,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    BarChartRodData(
                                      toY: _trend[i].income,
                                      color: AppColors.income,
                                      width: 6,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
