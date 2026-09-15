import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/domain_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/suggest_category.dart';
import '../../../data/repositories/providers.dart';
import '../../../domain/models/models.dart';

/// 新建/编辑一笔流水。
class LedgerEditPage extends ConsumerStatefulWidget {
  const LedgerEditPage({super.key, this.id, this.initialDate});

  final String? id;
  final String? initialDate;

  @override
  ConsumerState<LedgerEditPage> createState() => _LedgerEditPageState();
}

class _LedgerEditPageState extends ConsumerState<LedgerEditPage> {
  TxType _type = TxType.expense;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _category = '';
  String _payment = defaultPaymentMethod;
  String _occurredAt = todayDate();
  List<String> _suggestions = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _occurredAt = widget.initialDate ?? todayDate();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 1. 加载分类建议
    // 2. 若有 id 则回填编辑态
    final catRepo = ref.read(categoryRepositoryProvider);
    if (widget.id != null) {
      final tx = await ref.read(transactionRepositoryProvider).get(widget.id!);
      if (tx != null) {
        _type = tx.type;
        _amountCtrl.text = tx.amount.toString();
        _category = tx.category;
        _noteCtrl.text = tx.note;
        _payment = tx.paymentMethod;
        _occurredAt = tx.occurredAt;
      }
    }
    final cats = await catRepo.listByType(
      _type == TxType.expense ? CategoryKind.expense : CategoryKind.income,
    );
    _suggestions = cats.map((c) => c.name).toList();
    if (_category.isEmpty && _suggestions.isNotEmpty) {
      _category = _suggestions.first;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _switchType(TxType type) async {
    if (type == _type) return;
    setState(() => _type = type);
    final cats = await ref.read(categoryRepositoryProvider).listByType(
          type == TxType.expense ? CategoryKind.expense : CategoryKind.income,
        );
    setState(() {
      _suggestions = cats.map((c) => c.name).toList();
      _category = _suggestions.isNotEmpty ? _suggestions.first : '';
    });
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_occurredAt) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _occurredAt =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效金额')),
      );
      return;
    }
    if (_category.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写分类')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final kind =
          _type == TxType.expense ? CategoryKind.expense : CategoryKind.income;
      final cat = await ref
          .read(categoryRepositoryProvider)
          .ensure(kind, _category);
      await ref.read(transactionRepositoryProvider).save(
            id: widget.id,
            type: _type,
            amount: amount,
            category: cat,
            note: _noteCtrl.text.trim(),
            paymentMethod: _payment,
            occurredAt: _occurredAt,
          );
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppPageHeader(
        title: widget.id == null ? '记一笔' : '编辑流水',
        showBack: true,
        trailing: TextButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? '保存中' : '保存'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('支出')),
                        selected: _type == TxType.expense,
                        onSelected: (_) => _switchType(TxType.expense),
                        selectedColor: AppColors.expenseSoft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('收入')),
                        selected: _type == TxType.income,
                        onSelected: (_) => _switchType(TxType.income),
                        selectedColor: AppColors.incomeSoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixText: '¥ ',
                  ),
                ),
                const SizedBox(height: 16),
                SuggestCategory(
                  value: _category,
                  suggestions: _suggestions,
                  onChanged: (v) => setState(() => _category = v),
                ),
                const SizedBox(height: 16),
                const Text('支付方式', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: paymentMethods
                      .map(
                        (m) => ChoiceChip(
                          label: Text(m),
                          selected: _payment == m,
                          onSelected: (_) => setState(() => _payment = m),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('日期'),
                  trailing: Text(formatDateShort(_occurredAt)),
                  onTap: _pickDate,
                ),
                TextField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: '备注（可选）'),
                ),
              ],
            ),
    );
  }
}
