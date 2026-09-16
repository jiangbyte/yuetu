import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import 'app_text.dart';

/// 金额文字：支出红 / 收入绿。
class AmountText extends StatelessWidget {
  const AmountText(
    this.cents, {
    super.key,
    required this.isExpense,
    this.role = AppTextRole.body,
  });

  final int cents;
  final bool isExpense;
  final AppTextRole role;

  @override
  Widget build(BuildContext context) {
    final yuan = (cents.abs() / 100).toStringAsFixed(2);
    final prefix = isExpense ? '-' : '+';
    return AppText(
      '$prefix$yuan',
      role: role,
      color: isExpense ? AppColors.expense : AppColors.income,
      weight: AppTypography.medium,
    );
  }
}
