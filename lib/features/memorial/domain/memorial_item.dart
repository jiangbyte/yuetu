import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 纪念日类型。
enum MemorialType {
  festival,
  birthday,
  countdown,
  anniversary,
}

extension MemorialTypeX on MemorialType {
  String get label => switch (this) {
        MemorialType.festival => '节日',
        MemorialType.birthday => '生日',
        MemorialType.countdown => '倒数日',
        MemorialType.anniversary => '纪念日',
      };

  IconData get icon => switch (this) {
        MemorialType.festival => LucideIcons.partyPopper,
        MemorialType.birthday => LucideIcons.cake,
        MemorialType.countdown => LucideIcons.hourglass,
        MemorialType.anniversary => LucideIcons.heart,
      };

  Color get color => switch (this) {
        MemorialType.festival => const Color(0xFF36CFC9),
        MemorialType.birthday => const Color(0xFFF5222D),
        MemorialType.countdown => const Color(0xFF4A7DFF),
        MemorialType.anniversary => const Color(0xFFEB2F96),
      };

  Color get iconBg => switch (this) {
        MemorialType.festival => const Color(0xFFE6FFFB),
        MemorialType.birthday => const Color(0xFFFFF1F0),
        MemorialType.countdown => const Color(0xFFE8F0FF),
        MemorialType.anniversary => const Color(0xFFFFF0F6),
      };
}

/// 重复规则。
enum MemorialRepeat { none, yearly, monthly }

extension MemorialRepeatX on MemorialRepeat {
  String get label => switch (this) {
        MemorialRepeat.none => '不重复',
        MemorialRepeat.yearly => '每年',
        MemorialRepeat.monthly => '每月',
      };
}

/// 倒数/纪念日条目（内存假数据）。
class MemorialItem {
  const MemorialItem({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
    this.repeat = MemorialRepeat.none,
    this.showAge = false,
    this.reminder = '当天, 提前 3 天',
  });

  final String id;
  final String name;
  final DateTime date;
  final MemorialType type;
  final MemorialRepeat repeat;
  final bool showAge;
  final String reminder;

  DateTime get _origin => DateTime(date.year, date.month, date.day);

  DateTime _today([DateTime? now]) {
    final n = now ?? DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// 下次出现日（生日/节日循环）。
  DateTime nextOccurrence([DateTime? now]) {
    final today = _today(now);
    if (repeat == MemorialRepeat.none && type == MemorialType.countdown) {
      return _origin;
    }
    if (repeat == MemorialRepeat.monthly) {
      var next = DateTime(today.year, today.month, date.day);
      if (!next.isAfter(today)) {
        next = DateTime(today.year, today.month + 1, date.day);
      }
      return next;
    }
    // 默认按年
    var next = DateTime(today.year, date.month, date.day);
    if (!next.isAfter(today)) {
      next = DateTime(today.year + 1, date.month, date.day);
    }
    return next;
  }

  /// 是否用「已过」展示。
  bool get isPast {
    final today = _today();
    if (type == MemorialType.anniversary) return !_origin.isAfter(today);
    if (type == MemorialType.countdown) return _origin.isBefore(today);
    return false;
  }

  /// 展示天数（剩余或已过的绝对值）。
  int get displayDays {
    final today = _today();
    if (isPast) {
      return today.difference(_origin).inDays;
    }
    return nextOccurrence(today).difference(today).inDays;
  }

  String get statusLabel => isPast ? '已过天数' : '剩余天数';

  /// 详情页目标日文案用的日期。
  DateTime get highlightDate => isPast ? _origin : nextOccurrence();

  MemorialItem copyWith({
    String? name,
    DateTime? date,
    MemorialType? type,
    MemorialRepeat? repeat,
    bool? showAge,
    String? reminder,
  }) {
    return MemorialItem(
      id: id,
      name: name ?? this.name,
      date: date ?? this.date,
      type: type ?? this.type,
      repeat: repeat ?? this.repeat,
      showAge: showAge ?? this.showAge,
      reminder: reminder ?? this.reminder,
    );
  }
}
