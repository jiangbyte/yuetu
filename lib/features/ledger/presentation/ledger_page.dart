import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/domain_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color.dart';
import '../../../core/utils/date.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/day_section.dart';
import '../../../core/widgets/primary_fab.dart';
import '../../../core/widgets/swipe_delete.dart';
import '../../../domain/models/models.dart';
import '../application/ledger_provider.dart';

/// 流水首页：月汇总、日条、筛选与无限滚动。
class LedgerPage extends ConsumerWidget {
  const LedgerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ledgerProvider);
    final notifier = ref.read(ledgerProvider.notifier);
    final parts = splitYearMonth(state.ym);
    final days = listMonthDays(state.ym);
    final daysWithTx = {
      for (final i in state.list) i.occurredAt.substring(0, 10),
    };

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppPageHeader(
        title: '流水',
        trailing: IconButton(
          icon: const Icon(LucideIcons.pieChart, size: 20),
          onPressed: () => context.push('/reports?ym=${state.ym}'),
        ),
      ),
      floatingActionButton: PrimaryFab(
        onPressed: () async {
          await context.push('/ledger/edit?date=${state.selectedDay}');
          ref.read(ledgerProvider.notifier).refresh();
        },
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _SummaryCard(state: state, parts: parts, onMonth: notifier.switchMonth)),
            SliverToBoxAdapter(
              child: _DayStrip(
                days: days,
                selected: state.selectedDay,
                marked: daysWithTx,
                onSelect: notifier.selectDay,
              ),
            ),
            SliverToBoxAdapter(
              child: _FilterBar(
                direction: state.direction,
                tag: state.tag,
                chips: state.chipList,
                keyword: state.keyword,
                onDirection: notifier.setDirection,
                onTag: notifier.setTag,
                onKeyword: notifier.setKeyword,
              ),
            ),
            if (state.loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.visibleGroups.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    '暂无流水',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == state.visibleGroups.length) {
                      if (state.hasMore) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          notifier.loadMore();
                        });
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const SizedBox(height: 80);
                    }
                    final group = state.visibleGroups[index];
                    final income = group.items
                        .where((i) => i.type == TxType.income)
                        .fold<double>(0, (s, i) => s + i.amount);
                    final expense = group.items
                        .where((i) => i.type == TxType.expense)
                        .fold<double>(0, (s, i) => s + i.amount);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DaySection(
                          date: group.date,
                          income: income,
                          expense: expense,
                        ),
                        ...group.items.map(
                          (item) => SwipeDelete(
                            onDelete: () => notifier.remove(item.id),
                            child: _TxTile(
                              item: item,
                              colorHex: state.colorMap[item.category] ??
                                  colorForCategory(item.category),
                              onTap: () async {
                                  await context
                                      .push('/ledger/edit?id=${item.id}');
                                  ref.read(ledgerProvider.notifier).refresh();
                                },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: state.visibleGroups.length + 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.state,
    required this.parts,
    required this.onMonth,
  });

  final LedgerState state;
  final ({String year, String month}) parts;
  final void Function(int) onMonth;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sheet,
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => onMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${parts.year}年${parts.month}月',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _SumCell(label: '收入', value: state.summary.income, color: AppColors.income),
              _SumCell(label: '支出', value: state.summary.expense, color: AppColors.expense),
              _SumCell(label: '结余', value: state.summary.balance, color: AppColors.text),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '今日支出 ${formatMoney(state.todayExpense)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SumCell extends StatelessWidget {
  const _SumCell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            formatMoney(value),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.days,
    required this.selected,
    required this.marked,
    required this.onSelect,
  });

  final List<MonthDayItem> days;
  final String selected;
  final Set<String> marked;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final d = days[i];
          final active = d.date == selected;
          return GestureDetector(
            onTap: () => onSelect(d.date),
            child: Container(
              width: 48,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: active ? AppColors.accentSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    d.weekLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: active ? AppColors.accentDeep : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: active ? AppColors.accentDeep : AppColors.text,
                    ),
                  ),
                  if (marked.contains(d.date))
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.direction,
    required this.tag,
    required this.chips,
    required this.keyword,
    required this.onDirection,
    required this.onTag,
    required this.onKeyword,
  });

  final LedgerDirection direction;
  final String tag;
  final List<String> chips;
  final String keyword;
  final ValueChanged<LedgerDirection> onDirection;
  final ValueChanged<String> onTag;
  final ValueChanged<String> onKeyword;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          Row(
            children: [
              for (final d in LedgerDirection.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(switch (d) {
                      LedgerDirection.all => '全部',
                      LedgerDirection.expense => '支出',
                      LedgerDirection.income => '收入',
                    }),
                    selected: direction == d,
                    onSelected: (_) => onDirection(d),
                    selectedColor: AppColors.accentSoft,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: onKeyword,
            decoration: const InputDecoration(
              hintText: '搜索分类 / 备注 / 支付方式',
              prefixIcon: Icon(LucideIcons.search, size: 18),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: chips
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(c),
                        selected: tag == c,
                        onSelected: (_) => onTag(c),
                        selectedColor: hexToRgba('#3a8f83', 0.15),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({
    required this.item,
    required this.colorHex,
    required this.onTap,
  });

  final LedgerTransaction item;
  final String colorHex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sheet,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CategoryIcon(name: item.category, colorHex: colorHex),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (item.note.isNotEmpty || item.paymentMethod.isNotEmpty)
                      Text(
                        [
                          if (item.paymentMethod.isNotEmpty) item.paymentMethod,
                          if (item.note.isNotEmpty) item.note,
                        ].join(' · '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              AmountText(type: item.type.value, amount: item.amount),
            ],
          ),
        ),
      ),
    );
  }
}
