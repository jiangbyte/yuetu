import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 底栏可配置模块。
enum DockModule {
  tasks,
  calendar,
  ledger,
  notes,
  focus,
  checkin,
  memorial,
  more,
}

extension DockModuleX on DockModule {
  String get id => name;

  String get label => switch (this) {
        DockModule.tasks => '任务',
        DockModule.calendar => '日历',
        DockModule.ledger => '账本',
        DockModule.notes => '笔记',
        DockModule.focus => '专注',
        DockModule.checkin => '习惯',
        DockModule.memorial => '纪念日',
        DockModule.more => '更多',
      };

  /// Lucide 图标。
  IconData get icon => switch (this) {
        DockModule.tasks => LucideIcons.checkSquare,
        DockModule.calendar => LucideIcons.calendar,
        DockModule.ledger => LucideIcons.wallet,
        DockModule.notes => LucideIcons.stickyNote,
        DockModule.focus => LucideIcons.target,
        DockModule.checkin => LucideIcons.badgeCheck,
        DockModule.memorial => LucideIcons.heart,
        DockModule.more => LucideIcons.moreHorizontal,
      };

  String get routePath => switch (this) {
        DockModule.tasks => '/tasks',
        DockModule.calendar => '/calendar',
        DockModule.ledger => '/ledger',
        DockModule.notes => '/notes',
        DockModule.focus => '/focus',
        DockModule.checkin => '/checkin',
        DockModule.memorial => '/memorial',
        DockModule.more => '/more',
      };

  static DockModule? tryParse(String id) {
    for (final m in DockModule.values) {
      if (m.id == id) return m;
    }
    return null;
  }
}
