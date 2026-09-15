import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/date.dart';
import '../utils/money.dart';

/// 日分组标题：日期 + 当日收支小计。
class DaySection extends StatelessWidget {
  const DaySection({
    super.key,
    required this.date,
    required this.income,
    required this.expense,
  });

  final String date;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              formatDayLabel(date),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (income > 0)
            Text(
              '收 ${formatMoney(income)}',
              style: const TextStyle(fontSize: 12, color: AppColors.income),
            ),
          if (income > 0 && expense > 0) const SizedBox(width: 8),
          if (expense > 0)
            Text(
              '支 ${formatMoney(expense)}',
              style: const TextStyle(fontSize: 12, color: AppColors.expense),
            ),
        ],
      ),
    );
  }
}
