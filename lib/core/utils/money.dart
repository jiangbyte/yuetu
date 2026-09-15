import 'package:intl/intl.dart';

final _moneyFmt = NumberFormat('#,##0.00', 'zh_CN');

/// 格式化金额显示。
String formatMoney(num value) => _moneyFmt.format(value);

/// 带正负号的金额文案。
String signedMoney(String type, num value) {
  final prefix = type == 'income' ? '+' : '-';
  return '$prefix${formatMoney(value)}';
}
