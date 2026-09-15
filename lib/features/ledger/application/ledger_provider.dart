import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date.dart';
import '../../../data/repositories/providers.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../domain/models/models.dart';

enum LedgerDirection { all, income, expense }

class LedgerState {
  const LedgerState({
    required this.ym,
    required this.selectedDay,
    required this.summary,
    required this.list,
    required this.colorMap,
    required this.expenseTags,
    required this.incomeTags,
    required this.todayExpense,
    required this.direction,
    required this.tag,
    required this.keyword,
    required this.visibleCount,
    required this.loading,
  });

  final String ym;
  final String selectedDay;
  final MonthSummary summary;
  final List<LedgerTransaction> list;
  final Map<String, String> colorMap;
  final List<String> expenseTags;
  final List<String> incomeTags;
  final double todayExpense;
  final LedgerDirection direction;
  final String tag;
  final String keyword;
  final int visibleCount;
  final bool loading;

  static const pageSize = 20;

  LedgerState copyWith({
    String? ym,
    String? selectedDay,
    MonthSummary? summary,
    List<LedgerTransaction>? list,
    Map<String, String>? colorMap,
    List<String>? expenseTags,
    List<String>? incomeTags,
    double? todayExpense,
    LedgerDirection? direction,
    String? tag,
    String? keyword,
    int? visibleCount,
    bool? loading,
  }) {
    return LedgerState(
      ym: ym ?? this.ym,
      selectedDay: selectedDay ?? this.selectedDay,
      summary: summary ?? this.summary,
      list: list ?? this.list,
      colorMap: colorMap ?? this.colorMap,
      expenseTags: expenseTags ?? this.expenseTags,
      incomeTags: incomeTags ?? this.incomeTags,
      todayExpense: todayExpense ?? this.todayExpense,
      direction: direction ?? this.direction,
      tag: tag ?? this.tag,
      keyword: keyword ?? this.keyword,
      visibleCount: visibleCount ?? this.visibleCount,
      loading: loading ?? this.loading,
    );
  }

  List<String> get chipList {
    final fromRepo = direction == LedgerDirection.expense
        ? expenseTags
        : direction == LedgerDirection.income
            ? incomeTags
            : {...expenseTags, ...incomeTags}.toList();
    final fromData = list
        .where(
          (i) =>
              direction == LedgerDirection.all ||
              i.type.value == direction.name,
        )
        .map((i) => i.category)
        .where((c) => c.isNotEmpty);
    return ['全部', ...{...fromRepo, ...fromData}];
  }

  List<LedgerTransaction> get filteredList {
    final kw = keyword.trim().toLowerCase();
    return list.where((item) {
      if (item.occurredAt != selectedDay) return false;
      if (direction != LedgerDirection.all &&
          item.type.value != direction.name) {
        return false;
      }
      if (tag != '全部' && item.category != tag) return false;
      if (kw.isNotEmpty) {
        final hay =
            '${item.category}${item.note}${item.paymentMethod}'.toLowerCase();
        if (!hay.contains(kw)) return false;
      }
      return true;
    }).toList();
  }

  List<DayGroup> get visibleGroups {
    final sliced = filteredList.take(visibleCount).toList();
    return groupByDay(sliced);
  }

  bool get hasMore => filteredList.length > visibleCount;
}

class LedgerNotifier extends StateNotifier<LedgerState> {
  LedgerNotifier(this._ref)
      : super(
          LedgerState(
            ym: currentYearMonth(),
            selectedDay: defaultDayInMonth(currentYearMonth()),
            summary: MonthSummary.empty,
            list: const [],
            colorMap: const {},
            expenseTags: const [],
            incomeTags: const [],
            todayExpense: 0,
            direction: LedgerDirection.all,
            tag: '全部',
            keyword: '',
            visibleCount: LedgerState.pageSize,
            loading: true,
          ),
        ) {
    refresh();
  }

  final Ref _ref;

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    try {
      // 1. 并行拉取月汇总、流水、分类与今日支出
      // 2. 分类按收支两侧缓存，供 Tab 切换时立刻换 tag 列表
      final txRepo = _ref.read(transactionRepositoryProvider);
      final catRepo = _ref.read(categoryRepositoryProvider);
      final ym = state.ym;
      final results = await Future.wait([
        txRepo.monthSummary(ym),
        txRepo.listByMonth(ym),
        catRepo.colorMap(),
        txRepo.listByDate(todayDate()),
        catRepo.listByType(CategoryKind.expense),
        catRepo.listByType(CategoryKind.income),
      ]);
      final todayList = results[3] as List<LedgerTransaction>;
      state = state.copyWith(
        summary: results[0] as MonthSummary,
        list: results[1] as List<LedgerTransaction>,
        colorMap: results[2] as Map<String, String>,
        expenseTags:
            (results[4] as List<Category>).map((c) => c.name).toList(),
        incomeTags: (results[5] as List<Category>).map((c) => c.name).toList(),
        todayExpense: todayList
            .where((i) => i.type == TxType.expense)
            .fold<double>(0, (s, i) => s + i.amount),
        loading: false,
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  void switchMonth(int delta) {
    final ym = shiftYearMonth(state.ym, delta);
    state = state.copyWith(
      ym: ym,
      selectedDay: defaultDayInMonth(ym),
      tag: '全部',
      keyword: '',
      visibleCount: LedgerState.pageSize,
    );
    refresh();
  }

  void selectDay(String day) {
    state = state.copyWith(
      selectedDay: day,
      visibleCount: LedgerState.pageSize,
    );
  }

  void setDirection(LedgerDirection d) {
    if (d == state.direction) return;
    state = state.copyWith(
      direction: d,
      tag: '全部',
      visibleCount: LedgerState.pageSize,
    );
  }

  void setTag(String tag) {
    state = state.copyWith(tag: tag, visibleCount: LedgerState.pageSize);
  }

  void setKeyword(String keyword) {
    state = state.copyWith(keyword: keyword, visibleCount: LedgerState.pageSize);
  }

  void loadMore() {
    if (!state.hasMore) return;
    state = state.copyWith(
      visibleCount: state.visibleCount + LedgerState.pageSize,
    );
  }

  Future<void> remove(String id) async {
    await _ref.read(transactionRepositoryProvider).remove(id);
    await refresh();
  }
}

final ledgerProvider =
    StateNotifierProvider.autoDispose<LedgerNotifier, LedgerState>(
  LedgerNotifier.new,
);
