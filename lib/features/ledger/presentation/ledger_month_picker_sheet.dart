import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text.dart';
import '../application/ledger_provider.dart';

/// 月份选择底部面板：年切换 + 12 月网格（含收支摘要）。
class LedgerMonthPickerSheet extends ConsumerStatefulWidget {
  const LedgerMonthPickerSheet({
    super.key,
    required this.initial,
  });

  final DateTime initial;

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initial,
  }) {
    return showAppSheet<DateTime>(
      context: context,
      builder: (ctx) => LedgerMonthPickerSheet(initial: initial),
    );
  }

  @override
  ConsumerState<LedgerMonthPickerSheet> createState() =>
      _LedgerMonthPickerSheetState();
}

class _LedgerMonthPickerSheetState
    extends ConsumerState<LedgerMonthPickerSheet> {
  late int _year;
  late DateTime _selected;

  static const _selectedBg = Color(0xFFFFF1C9);
  static const _expenseTone = Color(0xFFE6A23C);

  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
    _selected = DateTime(widget.initial.year, widget.initial.month);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(ledgerProvider);
    final notifier = ref.read(ledgerProvider.notifier);
    final now = DateTime.now();

    return AppSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 标题 + 回本月 + 起始日
          Row(
            children: [
              const AppText('月份选择', role: AppTextRole.title),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () {
                  final m = DateTime(now.year, now.month);
                  Navigator.pop(context, m);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE08A),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: const AppText(
                    '回本月',
                    role: AppTextRole.caption,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const Spacer(),
              const AppText('起始日：1号', role: AppTextRole.caption),
              const SizedBox(width: 2),
              const AppIcon(
                LucideIcons.pencil,
                size: 14,
                color: AppColors.inkMuted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 2. 年切换
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => _year -= 1),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: AppIcon(LucideIcons.chevronLeft, size: 20),
                ),
              ),
              AppText('$_year年', role: AppTextRole.label),
              GestureDetector(
                onTap: () => setState(() => _year += 1),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: AppIcon(LucideIcons.chevronRight, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 3. 12 月网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, i) {
              final month = i + 1;
              final date = DateTime(_year, month);
              final selected = _selected.year == _year &&
                  _selected.month == month;
              final expense = notifier.monthExpense(date);
              final income = notifier.monthIncome(date);
              final hasData = expense > 0 || income > 0;

              return GestureDetector(
                onTap: () => Navigator.pop(context, date),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: selected ? _selectedBg : AppColors.canvas,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText('$month月', role: AppTextRole.caption),
                      const Spacer(),
                      if (hasData || selected) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: AppText(
                            expense > 0
                                ? '-${(expense / 100).toStringAsFixed(2)}'
                                : '0.00',
                            role: AppTextRole.caption,
                            color: _expenseTone,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: AppText(
                            (income / 100).toStringAsFixed(2),
                            role: AppTextRole.caption,
                            color: AppColors.income,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}
