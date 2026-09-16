import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_text.dart';
import '../application/ledger_provider.dart';
import '../domain/ledger_entry.dart';

/// 记一笔：分类网格 + 自定义数字键盘。
class LedgerEditPage extends ConsumerStatefulWidget {
  const LedgerEditPage({super.key});

  @override
  ConsumerState<LedgerEditPage> createState() => _LedgerEditPageState();
}

class _LedgerEditPageState extends ConsumerState<LedgerEditPage> {
  bool _expense = true;
  String _category = expenseCategories.first;
  String _amount = '0';
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cats = _expense ? expenseCategories : incomeCategories;
    if (!cats.contains(_category)) {
      _category = cats.first;
    }

    return Material(
      color: AppColors.surface,
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
                  _Seg(
                    label: '支出',
                    selected: _expense,
                    onTap: () => setState(() {
                      _expense = true;
                      _category = expenseCategories.first;
                    }),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _Seg(
                    label: '收入',
                    selected: !_expense,
                    onTap: () => setState(() {
                      _expense = false;
                      _category = incomeCategories.first;
                    }),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const AppText('取消', role: AppTextRole.label),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.page),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemCount: cats.length,
                itemBuilder: (context, i) {
                  final c = cats[i];
                  final selected = c == _category;
                  return GestureDetector(
                    onTap: () => setState(() => _category = c),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.canvas,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: AppText(
                            c.characters.first,
                            role: AppTextRole.label,
                            color: selected
                                ? AppColors.onPrimary
                                : AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AppText(c, role: AppTextRole.caption),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.page),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.stroke)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          _category,
                          role: AppTextRole.body,
                          weight: AppTypography.medium,
                        ),
                      ),
                      AppText(
                        _amount.contains('.')
                            ? _amount
                            : '$_amount.00',
                        role: AppTextRole.title,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: EditableText(
                      controller: _note,
                      focusNode: FocusNode(),
                      style: const TextStyle(
                        fontSize: AppTypography.caption,
                        color: AppColors.inkMuted,
                      ),
                      cursorColor: AppColors.primary,
                      backgroundCursorColor: AppColors.stroke,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _Keypad(
                    onKey: _onKey,
                    onDone: _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amount.length <= 1) {
          _amount = '0';
        } else {
          _amount = _amount.substring(0, _amount.length - 1);
        }
        return;
      }
      if (key == '.') {
        if (!_amount.contains('.')) _amount = '$_amount.';
        return;
      }
      if (_amount == '0' && key != '.') {
        _amount = key;
      } else {
        final parts = _amount.split('.');
        if (parts.length == 2 && parts[1].length >= 2) return;
        _amount = '$_amount$key';
      }
    });
  }

  void _submit() {
    // 1. 解析金额为分
    final yuan = double.tryParse(_amount) ?? 0;
    final cents = (yuan * 100).round();
    if (cents <= 0) return;
    // 2. 写入内存账本
    ref.read(ledgerProvider.notifier).add(
          LedgerEntry(
            id: 'l${DateTime.now().millisecondsSinceEpoch}',
            category: _category,
            cents: cents,
            isExpense: _expense,
            date: DateTime.now(),
            note: _note.text.trim(),
          ),
        );
    context.pop();
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AppText(
            label,
            role: AppTextRole.title,
            color: selected ? AppColors.ink : AppColors.inkMuted,
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 3,
            width: 28,
            color: selected ? AppColors.primary : const Color(0x00000000),
          ),
        ],
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey, required this.onDone});

  final ValueChanged<String> onKey;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3', '今天'],
      ['4', '5', '6', '+'],
      ['7', '8', '9', '-'],
      ['.', '0', '⌫', '完成'],
    ];
    return Column(
      children: [
        for (final row in keys)
          Row(
            children: [
              for (final k in row)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (k == '完成') {
                        onDone();
                      } else if (k != '今天' && k != '+' && k != '-') {
                        onKey(k);
                      }
                    },
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: k == '完成'
                            ? AppColors.primary
                            : AppColors.canvas,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      alignment: Alignment.center,
                      child: AppText(
                        k,
                        role: AppTextRole.label,
                        color: k == '完成'
                            ? AppColors.onPrimary
                            : AppColors.ink,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
