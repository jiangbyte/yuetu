/// 账本流水（金额单位：分）。
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.category,
    required this.cents,
    required this.isExpense,
    required this.date,
    this.note = '',
  });

  final String id;
  final String category;
  final int cents;
  final bool isExpense;
  final DateTime date;
  final String note;
}
