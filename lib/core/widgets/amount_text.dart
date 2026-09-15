import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/money.dart';

/// 带符号着色的金额文案。
class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.type,
    required this.amount,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  final String type;
  final double amount;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final isIncome = type == 'income';
    return Text(
      signedMoney(type, amount),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: isIncome ? AppColors.income : AppColors.expense,
      ),
    );
  }
}
