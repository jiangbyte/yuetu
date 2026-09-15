/// 日期工具：年月运算、月历格子、展示文案。
library;

String currentYearMonth() {
  final d = DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}';
}

String shiftYearMonth(String ym, int delta) {
  final parts = ym.split('-').map(int.parse).toList();
  final d = DateTime(parts[0], parts[1] + delta, 1);
  return '${d.year}-${d.month.toString().padLeft(2, '0')}';
}

({String start, String end}) monthRange(String ym) {
  final parts = ym.split('-').map(int.parse).toList();
  final last = DateTime(parts[0], parts[1] + 1, 0).day;
  return (
    start: '$ym-01',
    end: '$ym-${last.toString().padLeft(2, '0')}',
  );
}

String todayDate() {
  final d = DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class MonthDayItem {
  const MonthDayItem({
    required this.date,
    required this.day,
    required this.weekLabel,
  });

  final String date;
  final int day;
  final String weekLabel;
}

/// 生成当月横向日期条数据。
List<MonthDayItem> listMonthDays(String ym) {
  // 1. 解析年月并取当月天数
  // 2. 按日生成 ISO 日期与周几文案
  final parts = ym.split('-').map(int.parse).toList();
  final last = DateTime(parts[0], parts[1] + 1, 0).day;
  const week = ['日', '一', '二', '三', '四', '五', '六'];
  final days = <MonthDayItem>[];
  for (var day = 1; day <= last; day++) {
    final date = '$ym-${day.toString().padLeft(2, '0')}';
    // Dart weekday: Mon=1..Sun=7；对齐 JS getDay: Sun=0
    final jsWd = DateTime(parts[0], parts[1], day).weekday == 7
        ? 0
        : DateTime(parts[0], parts[1], day).weekday;
    days.add(MonthDayItem(date: date, day: day, weekLabel: '周${week[jsWd]}'));
  }
  return days;
}

String defaultDayInMonth(String ym) {
  final today = todayDate();
  if (today.startsWith('$ym-')) return today;
  return '$ym-01';
}

String formatDayLabel(String isoDate) {
  final d = DateTime.parse('${isoDate}T00:00:00');
  const week = ['日', '一', '二', '三', '四', '五', '六'];
  final wd = d.weekday == 7 ? 0 : d.weekday;
  final month = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$month月$day日 周${week[wd]}';
}

String formatDateShort(String isoDate) {
  final d = DateTime.tryParse('${isoDate}T00:00:00');
  if (d == null) return isoDate;
  return '${d.month.toString().padLeft(2, '0')}月${d.day.toString().padLeft(2, '0')}日';
}

String formatYearMonth(String ym) {
  final parts = ym.split('-');
  return '${parts[0]}年${int.parse(parts[1])}月';
}

String formatYearMonthShort(String ym) {
  final parts = ym.split('-');
  return '${int.parse(parts[1])}/${parts[0]}';
}

String yearMonthOf(String date) => date.substring(0, 7);

({String year, String month}) splitYearMonth(String ym) {
  final parts = ym.split('-');
  return (year: parts[0], month: '${int.parse(parts[1])}');
}

class MonthGridCell {
  const MonthGridCell({
    required this.date,
    required this.day,
    required this.inMonth,
    required this.isToday,
  });

  final String date;
  final int day;
  final bool inMonth;
  final bool isToday;
}

/// 构建月历格子（含上月/下月占位）。
List<MonthGridCell> buildMonthGrid(String ym) {
  final parts = ym.split('-').map(int.parse).toList();
  final y = parts[0];
  final m = parts[1];
  final first = DateTime(y, m, 1);
  final daysInMonth = DateTime(y, m + 1, 0).day;
  final startWeekday = first.weekday == 7 ? 0 : first.weekday;
  final cells = <MonthGridCell>[];
  final today = todayDate();

  final prevDays = DateTime(y, m, 0).day;
  for (var i = startWeekday - 1; i >= 0; i--) {
    final day = prevDays - i;
    final pm = m == 1 ? 12 : m - 1;
    final py = m == 1 ? y - 1 : y;
    final date =
        '$py-${pm.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    cells.add(MonthGridCell(
      date: date,
      day: day,
      inMonth: false,
      isToday: date == today,
    ));
  }

  for (var day = 1; day <= daysInMonth; day++) {
    final date = '$ym-${day.toString().padLeft(2, '0')}';
    cells.add(MonthGridCell(
      date: date,
      day: day,
      inMonth: true,
      isToday: date == today,
    ));
  }

  var next = 1;
  while (cells.length % 7 != 0) {
    final nm = m == 12 ? 1 : m + 1;
    final ny = m == 12 ? y + 1 : y;
    final date =
        '$ny-${nm.toString().padLeft(2, '0')}-${next.toString().padLeft(2, '0')}';
    cells.add(MonthGridCell(
      date: date,
      day: next,
      inMonth: false,
      isToday: date == today,
    ));
    next += 1;
  }

  return cells;
}

String formatDayShort(String isoDate) {
  final d = DateTime.parse('${isoDate}T00:00:00');
  return '${d.day}/${d.month}/${d.year}';
}
