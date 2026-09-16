import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dock_module.dart';

/// 默认可切换底栏：任务 | 日历 | 账本 | 专注 | 更多。
const defaultDockModules = <DockModule>[
  DockModule.tasks,
  DockModule.calendar,
  DockModule.ledger,
  DockModule.focus,
  DockModule.more,
];

/// 「更多」固定占最后一格；其余最多 4 个可配置。
class DockNotifier extends StateNotifier<List<DockModule>> {
  DockNotifier() : super(List<DockModule>.from(defaultDockModules));

  /// 用用户选择的模块重建底栏（末位强制 more）。
  void setModules(List<DockModule> selected) {
    // 1. 过滤 more，最多取 4 个
    final core = selected.where((m) => m != DockModule.more).take(4).toList();
    // 2. 末尾固定更多
    state = [...core, DockModule.more];
  }

  void moveUp(int index) {
    if (index <= 0 || index >= state.length - 1) return;
    final next = [...state];
    final tmp = next[index - 1];
    next[index - 1] = next[index];
    next[index] = tmp;
    state = next;
  }

  void moveDown(int index) {
    if (index < 0 || index >= state.length - 2) return;
    final next = [...state];
    final tmp = next[index + 1];
    next[index + 1] = next[index];
    next[index] = tmp;
    state = next;
  }

  void toggle(DockModule module) {
    if (module == DockModule.more) return;
    final core = state.where((m) => m != DockModule.more).toList();
    if (core.contains(module)) {
      if (core.length <= 1) return;
      core.remove(module);
    } else {
      if (core.length >= 4) return;
      core.add(module);
    }
    state = [...core, DockModule.more];
  }
}

final dockProvider =
    StateNotifierProvider<DockNotifier, List<DockModule>>((ref) {
  return DockNotifier();
});

/// 底栏是否显示（任务多选等场景临时隐藏）。
final dockVisibleProvider = StateProvider<bool>((ref) => true);
