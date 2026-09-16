import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/habit_item.dart';

/// 习惯打卡内存状态。
class HabitsState {
  const HabitsState({
    required this.habits,
    required this.selectedDay,
    required this.checkedKeys,
  });

  final List<HabitItem> habits;
  final DateTime selectedDay;

  /// 已打卡键：`$habitId|$yyyy-m-d`。
  final Set<String> checkedKeys;

  /// 按分组归类。
  Map<String, List<HabitItem>> get grouped {
    final map = <String, List<HabitItem>>{};
    for (final h in habits) {
      map.putIfAbsent(h.group, () => []).add(h);
    }
    return map;
  }

  bool isChecked(String habitId, DateTime day) {
    return checkedKeys.contains(_key(habitId, day));
  }

  /// 今日是否至少打卡一次（供「更多」页徽章）。
  bool get checkedToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final h in habits) {
      if (isChecked(h.id, today)) return true;
    }
    return false;
  }

  /// 当前最大连续天数（供徽章展示）。
  int get maxStreak {
    var max = 0;
    for (final h in habits) {
      if (h.currentStreak > max) max = h.currentStreak;
    }
    return max;
  }

  HabitItem? byId(String id) {
    for (final h in habits) {
      if (h.id == id) return h;
    }
    return null;
  }

  HabitsState copyWith({
    List<HabitItem>? habits,
    DateTime? selectedDay,
    Set<String>? checkedKeys,
  }) {
    return HabitsState(
      habits: habits ?? this.habits,
      selectedDay: selectedDay ?? this.selectedDay,
      checkedKeys: checkedKeys ?? this.checkedKeys,
    );
  }

  static String _key(String habitId, DateTime day) =>
      '$habitId|${day.year}-${day.month}-${day.day}';
}

/// 习惯增删改与打卡。
class HabitsNotifier extends StateNotifier<HabitsState> {
  HabitsNotifier()
      : super(
          HabitsState(
            habits: const [],
            selectedDay: _today(),
            checkedKeys: {},
          ),
        );

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// 切换选中日。
  void selectDay(DateTime day) {
    state = state.copyWith(
      selectedDay: DateTime(day.year, day.month, day.day),
    );
  }

  /// 新增习惯。
  void add(HabitItem habit) {
    state = state.copyWith(habits: [habit, ...state.habits]);
  }

  /// 从模板快速添加。
  void addFromTemplate(HabitTemplate tpl) {
    // 1. 生成 id 与默认分组
    final habit = HabitItem(
      id: 'h${DateTime.now().millisecondsSinceEpoch}',
      name: tpl.name,
      encourage: tpl.desc,
      icon: tpl.icon,
      iconBg: tpl.iconBg,
      group: '其他',
      startDate: _today(),
    );
    add(habit);
  }

  /// 对某日完成打卡。
  void checkIn(String habitId, {DateTime? day}) {
    // 1. 幂等：已打过则忽略
    final d = day ?? state.selectedDay;
    final key = HabitsState._key(habitId, d);
    if (state.checkedKeys.contains(key)) return;
    // 2. 记打卡键并刷新连续/总计
    final nextKeys = {...state.checkedKeys, key};
    state = state.copyWith(
      checkedKeys: nextKeys,
      habits: [
        for (final h in state.habits)
          if (h.id == habitId)
            h.copyWith(
              totalCheckIns: h.totalCheckIns + 1,
              currentStreak: h.currentStreak + 1,
              bestStreak: (h.currentStreak + 1) > h.bestStreak
                  ? h.currentStreak + 1
                  : h.bestStreak,
            )
          else
            h,
      ],
    );
  }

  HabitItem? byId(String id) => state.byId(id);
}

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, HabitsState>((ref) {
  return HabitsNotifier();
});
