import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/memorial_item.dart';

/// 倒数纪念日内存状态。
class MemorialNotifier extends StateNotifier<List<MemorialItem>> {
  MemorialNotifier()
      : super([
          MemorialItem(
            id: 'm1',
            name: '周末',
            date: _nextWeekend(),
            type: MemorialType.countdown,
          ),
          MemorialItem(
            id: 'm2',
            name: '春节',
            date: DateTime(2027, 2, 6),
            type: MemorialType.festival,
            repeat: MemorialRepeat.yearly,
          ),
          MemorialItem(
            id: 'm3',
            name: '使用月兔',
            date: DateTime(2023, 11, 26),
            type: MemorialType.anniversary,
            repeat: MemorialRepeat.yearly,
          ),
        ]);

  static DateTime _nextWeekend() {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    // 1. 找下一个周六
    final delta = (DateTime.saturday - today.weekday + 7) % 7;
    final days = delta == 0 ? 7 : delta;
    return today.add(Duration(days: days));
  }

  /// 新增。
  void add(MemorialItem item) {
    state = [item, ...state];
  }

  /// 更新。
  void update(MemorialItem item) {
    state = [
      for (final m in state)
        if (m.id == item.id) item else m,
    ];
  }

  /// 删除。
  void remove(String id) {
    state = [for (final m in state) if (m.id != id) m];
  }

  MemorialItem? byId(String id) {
    for (final m in state) {
      if (m.id == id) return m;
    }
    return null;
  }
}

final memorialProvider =
    StateNotifierProvider<MemorialNotifier, List<MemorialItem>>((ref) {
  return MemorialNotifier();
});
