import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 习惯频率类型。
enum HabitFrequency { daily, weekly, interval }

/// 习惯条目（内存假数据，后续再接库）。
class HabitItem {
  const HabitItem({
    required this.id,
    required this.name,
    required this.encourage,
    required this.icon,
    required this.iconBg,
    this.group = '其他',
    this.frequency = HabitFrequency.daily,
    this.weekdays = const [0, 1, 2, 3, 4, 5, 6],
    this.startDate,
    this.totalCheckIns = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  final String id;
  final String name;
  final String encourage;
  final IconData icon;
  final Color iconBg;
  final String group;
  final HabitFrequency frequency;

  /// 0=日 … 6=六，按天频率时生效。
  final List<int> weekdays;
  final DateTime? startDate;
  final int totalCheckIns;
  final int currentStreak;
  final int bestStreak;

  HabitItem copyWith({
    String? name,
    String? encourage,
    IconData? icon,
    Color? iconBg,
    String? group,
    HabitFrequency? frequency,
    List<int>? weekdays,
    DateTime? startDate,
    int? totalCheckIns,
    int? currentStreak,
    int? bestStreak,
  }) {
    return HabitItem(
      id: id,
      name: name ?? this.name,
      encourage: encourage ?? this.encourage,
      icon: icon ?? this.icon,
      iconBg: iconBg ?? this.iconBg,
      group: group ?? this.group,
      frequency: frequency ?? this.frequency,
      weekdays: weekdays ?? this.weekdays,
      startDate: startDate ?? this.startDate,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }
}

/// 习惯库模板。
class HabitTemplate {
  const HabitTemplate({
    required this.id,
    required this.name,
    required this.desc,
    required this.category,
    required this.icon,
    required this.iconBg,
  });

  final String id;
  final String name;
  final String desc;
  final String category;
  final IconData icon;
  final Color iconBg;
}

/// 内置习惯库分类与模板。
abstract final class HabitCatalog {
  static const categories = ['推荐', '生活', '健康', '运动', '心态'];

  static const groups = ['下午', '晚上', '其他'];

  static final templates = <HabitTemplate>[
    HabitTemplate(
      id: 'tpl1',
      name: '每天进步一点点',
      desc: '来月兔里简单 check 每一天',
      category: '推荐',
      icon: LucideIcons.smile,
      iconBg: const Color(0xFFFFF3C4),
    ),
    HabitTemplate(
      id: 'tpl2',
      name: '喝水',
      desc: '记得按时补充水分',
      category: '健康',
      icon: LucideIcons.cupSoda,
      iconBg: const Color(0xFFD6E4FF),
    ),
    HabitTemplate(
      id: 'tpl3',
      name: '吃早餐',
      desc: '再忙也不要落下早餐哦',
      category: '生活',
      icon: LucideIcons.sandwich,
      iconBg: const Color(0xFFFFE7D1),
    ),
    HabitTemplate(
      id: 'tpl4',
      name: '吃水果',
      desc: '饭后来点水果就更棒了',
      category: '健康',
      icon: LucideIcons.apple,
      iconBg: const Color(0xFFD9F7BE),
    ),
    HabitTemplate(
      id: 'tpl5',
      name: '早起',
      desc: '神清气爽迎接新的一天',
      category: '生活',
      icon: LucideIcons.sun,
      iconBg: const Color(0xFFFFF1B8),
    ),
    HabitTemplate(
      id: 'tpl6',
      name: '早睡',
      desc: '注意身体，别熬夜',
      category: '生活',
      icon: LucideIcons.moon,
      iconBg: const Color(0xFFD6E4FF),
    ),
    HabitTemplate(
      id: 'tpl7',
      name: '背单词',
      desc: '学习一门语言当然要背单词哎',
      category: '心态',
      icon: LucideIcons.bookOpen,
      iconBg: const Color(0xFFFFE7BA),
    ),
    HabitTemplate(
      id: 'tpl8',
      name: '运动',
      desc: '动一动，身体更轻盈',
      category: '运动',
      icon: LucideIcons.dumbbell,
      iconBg: const Color(0xFFFFCCC7),
    ),
  ];

  /// 可选图标（新建页网格）。
  static const icons = <(IconData, Color)>[
    (LucideIcons.smile, Color(0xFFFFF3C4)),
    (LucideIcons.cupSoda, Color(0xFFD6E4FF)),
    (LucideIcons.sandwich, Color(0xFFFFE7D1)),
    (LucideIcons.apple, Color(0xFFD9F7BE)),
    (LucideIcons.sun, Color(0xFFFFF1B8)),
    (LucideIcons.moon, Color(0xFFD6E4FF)),
    (LucideIcons.bookOpen, Color(0xFFFFE7BA)),
    (LucideIcons.dumbbell, Color(0xFFFFCCC7)),
    (LucideIcons.heart, Color(0xFFFFCCC7)),
    (LucideIcons.music, Color(0xFFEBD4FF)),
    (LucideIcons.bike, Color(0xFFB5F5EC)),
    (LucideIcons.coffee, Color(0xFFFFE7D1)),
    (LucideIcons.leaf, Color(0xFFD9F7BE)),
    (LucideIcons.pencil, Color(0xFFD6E4FF)),
  ];
}
