import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text.dart';
import '../application/ledger_provider.dart';

/// 本月预算页：总预算进度 + 明细（暂空）。
class LedgerBudgetPage extends ConsumerWidget {
  const LedgerBudgetPage({super.key, required this.month});

  /// `yyyy-M` 查询参数解析后的月份。
  final DateTime month;

  static String _yuan(int cents) =>
      '¥ ${(cents.abs() / 100).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ledgerProvider);
    final notifier = ref.read(ledgerProvider.notifier);
    final budget = notifier.monthBudget(month);
    final used = notifier.monthExpense(month);
    final available = budget - used;
    final ratio = budget <= 0 ? 0.0 : (used / budget).clamp(0.0, 1.0);
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final range =
        '${month.year}.${month.month}.1-${month.month}.$lastDay';

    return Material(
      color: AppColors.canvas,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const AppIcon(LucideIcons.arrowLeft, size: 22),
                  ),
                  const Expanded(
                    child: Center(
                      child: AppText('本月预算', role: AppTextRole.pageTitle),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        ref.read(ledgerProvider.notifier).resetMonthBudget(month),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C6370),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: const AppText(
                        '重置',
                        role: AppTextRole.caption,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppText(range, role: AppTextRole.caption),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            const AppText('支出总预算', role: AppTextRole.body),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _editBudget(context, ref, budget),
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                children: [
                                  AppText(
                                    _yuan(budget),
                                    role: AppTextRole.title,
                                    weight: AppTypography.bold,
                                  ),
                                  const SizedBox(width: 4),
                                  const AppIcon(
                                    LucideIcons.pencil,
                                    size: 16,
                                    color: AppColors.inkMuted,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // 进度条
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          child: SizedBox(
                            height: 10,
                            child: Stack(
                              children: [
                                const ColoredBox(
                                  color: AppColors.stroke,
                                  child: SizedBox.expand(),
                                ),
                                FractionallySizedBox(
                                  widthFactor: ratio,
                                  child: const ColoredBox(
                                    color: Color(0xFF5C6370),
                                    child: SizedBox.expand(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        CustomPaint(
                          painter: _DashLinePainter(),
                          child: const SizedBox(
                            height: 1,
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppText('已用', role: AppTextRole.caption),
                                AppText(
                                  _yuan(used),
                                  role: AppTextRole.body,
                                  weight: AppTypography.medium,
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const AppText('可用', role: AppTextRole.caption),
                                AppText(
                                  _yuan(available),
                                  role: AppTextRole.body,
                                  weight: AppTypography.medium,
                                  color: available < 0
                                      ? AppColors.expense
                                      : AppColors.ink,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Row(
                    children: [
                      AppText('预算明细', role: AppTextRole.label),
                      Spacer(),
                      AppText(
                        '+ 添加',
                        role: AppTextRole.caption,
                        color: AppColors.inkMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const AppEmptyState(
                    title: '尚未添加预算明细',
                    subtitle: '快去添加吧',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editBudget(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final cents = await _SetBudgetSheet.show(context, initialCents: current);
    if (cents == null) return;
    ref.read(ledgerProvider.notifier).setMonthBudget(month, cents);
  }
}

/// 虚线分隔。
class _DashLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.stroke
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 3.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 设置预算金额面板。
class _SetBudgetSheet extends StatefulWidget {
  const _SetBudgetSheet({required this.initialCents});

  final int initialCents;

  static Future<int?> show(
    BuildContext context, {
    required int initialCents,
  }) {
    return showAppSheet<int>(
      context: context,
      builder: (ctx) => _SetBudgetSheet(initialCents: initialCents),
    );
  }

  @override
  State<_SetBudgetSheet> createState() => _SetBudgetSheetState();
}

class _SetBudgetSheetState extends State<_SetBudgetSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final yuan = widget.initialCents > 0
        ? (widget.initialCents / 100).toStringAsFixed(2)
        : '';
    _controller = TextEditingController(text: yuan);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    // 1. 解析元 → 分
    final raw = _controller.text.trim().replaceAll(',', '');
    final yuan = double.tryParse(raw);
    if (yuan == null || yuan < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效金额')),
      );
      return;
    }
    // 2. 回传分
    Navigator.pop(context, (yuan * 100).round());
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const AppIcon(LucideIcons.arrowLeft, size: 22),
              ),
              const SizedBox(width: AppSpacing.sm),
              const AppText('设置预算', role: AppTextRole.title),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            cursorColor: AppColors.primary,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              backgroundColor: Color(0x00000000),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.canvas,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: _confirm,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              alignment: Alignment.center,
              child: const AppText(
                '确认',
                role: AppTextRole.label,
                color: AppColors.onPrimary,
              ),
            ),
          ),
          // IME 避让由 showAppSheet 统一垫高，这里不再叠 viewInsets
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
