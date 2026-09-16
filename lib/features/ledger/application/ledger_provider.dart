import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/ledger_entry.dart';

/// 账本条目 + 按月预算（分）。
class LedgerState {
  const LedgerState({
    required this.entries,
    this.budgets = const {},
  });

  final List<LedgerEntry> entries;

  /// key: `yyyy-M` → 支出总预算（分）。
  final Map<String, int> budgets;

  static String monthKey(DateTime month) => '${month.year}-${month.month}';

  LedgerState copyWith({
    List<LedgerEntry>? entries,
    Map<String, int>? budgets,
  }) {
    return LedgerState(
      entries: entries ?? this.entries,
      budgets: budgets ?? this.budgets,
    );
  }
}

class LedgerNotifier extends StateNotifier<LedgerState> {
  LedgerNotifier()
      : super(
          LedgerState(
            entries: [
              LedgerEntry(
                id: 'l1',
                category: '餐饮',
                cents: 3200,
                isExpense: true,
                date: DateTime(2026, 9, 16),
                note: '午餐',
              ),
              LedgerEntry(
                id: 'l2',
                category: '交通',
                cents: 600,
                isExpense: true,
                date: DateTime(2026, 9, 16),
              ),
              LedgerEntry(
                id: 'l3',
                category: '购物',
                cents: 58100,
                isExpense: true,
                date: DateTime(2026, 9, 10),
              ),
            ],
            // 演示：本月预算 ¥2536
            budgets: {'2026-9': 253600},
          ),
        );

  void add(LedgerEntry entry) {
    state = state.copyWith(entries: [entry, ...state.entries]);
  }

  int monthExpense(DateTime month) {
    return state.entries
        .where((e) =>
            e.isExpense &&
            e.date.year == month.year &&
            e.date.month == month.month)
        .fold(0, (s, e) => s + e.cents);
  }

  int monthIncome(DateTime month) {
    return state.entries
        .where((e) =>
            !e.isExpense &&
            e.date.year == month.year &&
            e.date.month == month.month)
        .fold(0, (s, e) => s + e.cents);
  }

  /// 本月支出总预算（分）；未设置则为 0。
  int monthBudget(DateTime month) {
    return state.budgets[LedgerState.monthKey(month)] ?? 0;
  }

  /// 设置/更新某月预算。
  void setMonthBudget(DateTime month, int cents) {
    final next = Map<String, int>.from(state.budgets);
    final key = LedgerState.monthKey(month);
    if (cents <= 0) {
      next.remove(key);
    } else {
      next[key] = cents;
    }
    state = state.copyWith(budgets: next);
  }

  /// 清空某月预算。
  void resetMonthBudget(DateTime month) {
    setMonthBudget(month, 0);
  }

  /// 今日已支出（分）。
  int todayExpense([DateTime? now]) {
    final n = now ?? DateTime.now();
    return state.entries
        .where((e) =>
            e.isExpense &&
            e.date.year == n.year &&
            e.date.month == n.month &&
            e.date.day == n.day)
        .fold(0, (s, e) => s + e.cents);
  }

  /// 今日可用：月预算剩余均摊到剩余天数，再扣今日已花。
  int todayAvailable(DateTime month, [DateTime? now]) {
    return _dailyShare(month, now) - _todaySpendIfCurrent(month, now);
  }

  /// 今日额度（未扣今日已花），用于圆环进度分母。
  int todayQuota(DateTime month, [DateTime? now]) {
    return _dailyShare(month, now);
  }

  int _dailyShare(DateTime month, [DateTime? now]) {
    // 1. 定位「今天」；非当前月则按该月最后一天估算
    final n = now ?? DateTime.now();
    final inThisMonth = n.year == month.year && n.month == month.month;
    final day = inThisMonth
        ? n.day
        : DateTime(month.year, month.month + 1, 0).day;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final remainingDays = daysInMonth - day + 1;
    // 2. 优先用预算剩余；无预算时用收入−支出
    final budget = monthBudget(month);
    final used = monthExpense(month);
    final leftover =
        budget > 0 ? budget - used : monthIncome(month) - used;
    return leftover ~/ remainingDays;
  }

  int _todaySpendIfCurrent(DateTime month, [DateTime? now]) {
    final n = now ?? DateTime.now();
    final inThisMonth = n.year == month.year && n.month == month.month;
    if (!inThisMonth) return 0;
    return todayExpense(n);
  }
}

final ledgerProvider =
    StateNotifierProvider<LedgerNotifier, LedgerState>((ref) {
  return LedgerNotifier();
});

const expenseCategories = [
  '餐饮',
  '购物',
  '日用',
  '交通',
  '零食',
  '娱乐',
  '通讯',
  '住房',
  '医疗',
  '学习',
  '数码',
  '其他',
];

const incomeCategories = [
  '工资',
  '奖金',
  '理财',
  '红包',
  '兼职',
  '其他',
];
