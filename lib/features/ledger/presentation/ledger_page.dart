import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_fab.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_text.dart';
import '../application/ledger_provider.dart';
import '../domain/ledger_entry.dart';
import 'ledger_month_picker_sheet.dart';

/// 账本明细：顶部汇总卡 + 按日分组列表。
class LedgerPage extends ConsumerStatefulWidget {
  const LedgerPage({super.key});

  @override
  ConsumerState<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends ConsumerState<LedgerPage> {
  /// 当前查看月份。
  late DateTime _month;

  /// true=看本月支出，false=看本月收入。
  var _showExpense = true;

  static const _cardCream = Color(0xFFFFF6E8);
  static const _todayAccent = Color(0xFFC47A3A);

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
  }

  /// 切换查看月份。
  Future<void> _pickMonth() async {
    final picked = await LedgerMonthPickerSheet.show(
      context,
      initial: _month,
    );
    if (picked != null) {
      setState(() => _month = DateTime(picked.year, picked.month));
    }
  }

  /// 进入本月预算。
  void _openBudget() {
    context.push(
      '/ledger/budget?year=${_month.year}&month=${_month.month}',
    );
  }

  /// 格式化分→元，可选正负号。
  String _yuan(int cents, {bool signed = false}) {
    final abs = (cents.abs() / 100).toStringAsFixed(2);
    if (!signed) return '¥$abs';
    if (cents > 0) return '+¥$abs';
    if (cents < 0) return '-¥$abs';
    return '¥$abs';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ledgerProvider);
    final entries = state.entries;
    final notifier = ref.read(ledgerProvider.notifier);
    final expense = notifier.monthExpense(_month);
    final income = notifier.monthIncome(_month);
    final balance = income - expense;
    final primaryCents = _showExpense ? expense : income;
    final todayAvailable = notifier.todayAvailable(_month);
    final todayQuota = notifier.todayQuota(_month);
    final todayProgress = todayQuota <= 0
        ? (todayAvailable < 0 ? 0.0 : 1.0)
        : (todayAvailable / todayQuota).clamp(0.0, 1.0);

    final monthEntries = entries
        .where((e) =>
            e.date.year == _month.year && e.date.month == _month.month)
        .toList();
    final grouped = <String, List<LedgerEntry>>{};
    for (final e in monthEntries) {
      final key =
          '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(e);
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _RecordHeader(),
              _SummaryCard(
                cream: _cardCream,
                monthLabel: '${_month.year}年${_month.month}月',
                onPickMonth: _pickMonth,
                showExpense: _showExpense,
                onTogglePrimary: () =>
                    setState(() => _showExpense = !_showExpense),
                primaryLabel: _showExpense ? '本月支出' : '本月收入',
                primaryYuan: _yuan(primaryCents),
                incomeYuan: _yuan(income),
                balanceYuan: _yuan(balance, signed: true),
                balanceCents: balance,
                todayYuan: _yuan(todayAvailable, signed: true),
                todayCents: todayAvailable,
                todayProgress: todayProgress,
                todayAccent: _todayAccent,
                onTodayTap: _openBudget,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView(
                  children: [
                    for (final key in grouped.keys) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: AppText(
                          _dayLabel(key, grouped[key]!),
                          role: AppTextRole.caption,
                        ),
                      ),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (var i = 0; i < grouped[key]!.length; i++) ...[
                              if (i > 0)
                                const ColoredBox(
                                  color: AppColors.stroke,
                                  child: SizedBox(
                                    height: 1,
                                    width: double.infinity,
                                  ),
                                ),
                              _EntryRow(entry: grouped[key]![i]),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: AppSpacing.page,
          bottom: AppFab.clearanceOf(context),
          child: AppFab(onPressed: () => context.push('/ledger/edit')),
        ),
      ],
    );
  }

  String _dayLabel(String key, List<LedgerEntry> list) {
    final dayExpense =
        list.where((e) => e.isExpense).fold(0, (s, e) => s + e.cents);
    return '$key  支 ${(dayExpense / 100).toStringAsFixed(2)}';
  }
}

/// 「记录」标题 + 橙色笔触下划线。
class _RecordHeader extends StatelessWidget {
  const _RecordHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Row(
        children: [
          const AppIcon(LucideIcons.menu, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const AppText('记录', role: AppTextRole.pageTitle),
              Positioned(
                left: 0,
                bottom: -2,
                child: CustomPaint(
                  size: const Size(22, 6),
                  painter: _BrushStrokePainter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 手绘感橙色下划线。
class _BrushStrokePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFB84D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.1,
        size.width,
        size.height * 0.7,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 月度汇总奶油色卡片。
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.cream,
    required this.monthLabel,
    required this.onPickMonth,
    required this.showExpense,
    required this.onTogglePrimary,
    required this.primaryLabel,
    required this.primaryYuan,
    required this.incomeYuan,
    required this.balanceYuan,
    required this.balanceCents,
    required this.todayYuan,
    required this.todayCents,
    required this.todayProgress,
    required this.todayAccent,
    required this.onTodayTap,
  });

  final Color cream;
  final String monthLabel;
  final VoidCallback onPickMonth;
  final bool showExpense;
  final VoidCallback onTogglePrimary;
  final String primaryLabel;
  final String primaryYuan;
  final String incomeYuan;
  final String balanceYuan;
  final int balanceCents;
  final String todayYuan;
  final int todayCents;
  final double todayProgress;
  final Color todayAccent;
  final VoidCallback onTodayTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. 月份选择 + 统计入口
          Row(
            children: [
              GestureDetector(
                onTap: onPickMonth,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(monthLabel, role: AppTextRole.label),
                    const SizedBox(width: 2),
                    const AppIcon(
                      LucideIcons.chevronDown,
                      size: 16,
                      color: AppColors.inkMuted,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText('统计报表', role: AppTextRole.caption),
                    AppIcon(
                      LucideIcons.chevronRight,
                      size: 14,
                      color: AppColors.inkMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 2. 主金额 + 今日可用
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(primaryLabel, role: AppTextRole.caption),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: AppText(
                            primaryYuan,
                            role: AppTextRole.display,
                            weight: AppTypography.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        GestureDetector(
                          onTap: onTogglePrimary,
                          child: const AppIcon(
                            LucideIcons.arrowLeftRight,
                            size: 18,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        AppText(
                          '收入 $incomeYuan',
                          role: AppTextRole.caption,
                          color: AppColors.income,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AppText(
                          '结余 $balanceYuan',
                          role: AppTextRole.caption,
                          color: balanceCents < 0
                              ? AppColors.expense
                              : AppColors.ink,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onTodayTap,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: CustomPaint(
                    painter: _TodayRingPainter(
                      progress: todayProgress,
                      overspent: todayCents < 0,
                      accent: todayAccent,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: AppText(
                                todayYuan,
                                role: AppTextRole.caption,
                                color: todayCents < 0
                                    ? AppColors.expense
                                    : AppColors.ink,
                                weight: AppTypography.bold,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            AppText(
                              '今日可用',
                              role: AppTextRole.caption,
                              color: todayAccent,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 今日可用圆环进度。
class _TodayRingPainter extends CustomPainter {
  _TodayRingPainter({
    required this.progress,
    required this.overspent,
    required this.accent,
  });

  final double progress;
  final bool overspent;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 4;
    final track = Paint()
      ..color = accent.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = overspent ? AppColors.expense : accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    final sweep = overspent ? 2 * 3.14159265 : 2 * 3.14159265 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265 / 2,
      sweep,
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _TodayRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.overspent != overspent ||
        oldDelegate.accent != accent;
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppText(
              entry.category.characters.first,
              role: AppTextRole.caption,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: AppText(entry.category, role: AppTextRole.body)),
          AmountText(entry.cents, isExpense: entry.isExpense),
        ],
      ),
    );
  }
}
