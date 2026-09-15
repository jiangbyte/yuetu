import '../../core/constants/domain_constants.dart';
import '../../core/utils/date.dart';
import '../../core/utils/id.dart';
import '../../domain/models/models.dart';
import '../db/app_database.dart';
import 'package:drift/drift.dart';

/// 流水仓储：月列表、汇总、报表聚合与 CRUD。
class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;

  LedgerTransaction _map(Transaction row) => LedgerTransaction(
        id: row.id,
        type: TxType.fromValue(row.type),
        amount: row.amount,
        category: row.category,
        note: row.note,
        paymentMethod: row.paymentMethod,
        occurredAt: row.occurredAt,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  Future<List<LedgerTransaction>> listByMonth(String ym) async {
    final range = monthRange(ym);
    final rows = await (_db.select(_db.transactions)
          ..where(
            (t) =>
                t.occurredAt.isBiggerOrEqualValue(range.start) &
                t.occurredAt.isSmallerOrEqualValue(range.end),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.occurredAt),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
    return rows.map(_map).toList();
  }

  Future<List<LedgerTransaction>> listByDate(String date) async {
    final rows = await (_db.select(_db.transactions)
          ..where((t) => t.occurredAt.equals(date))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_map).toList();
  }

  /// 某月每天是否有流水（日历圆点）。
  Future<Map<String, DayMark>> dayMarksByMonth(String ym) async {
    final range = monthRange(ym);
    final result = await _db.customSelect(
      '''
      SELECT
        occurred_at AS day,
        COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS income,
        COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS expense,
        COUNT(1) AS cnt
      FROM transactions
      WHERE occurred_at >= ? AND occurred_at <= ?
      GROUP BY occurred_at
      ''',
      variables: [Variable.withString(range.start), Variable.withString(range.end)],
      readsFrom: {_db.transactions},
    ).get();

    final map = <String, DayMark>{};
    for (final row in result) {
      map[row.read<String>('day')] = DayMark(
        income: row.read<double>('income'),
        expense: row.read<double>('expense'),
        count: row.read<int>('cnt'),
      );
    }
    return map;
  }

  Future<LedgerTransaction?> get(String id) async {
    final row = await (_db.select(_db.transactions)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _map(row);
  }

  Future<String> save({
    String? id,
    required TxType type,
    required double amount,
    required String category,
    String? note,
    String? paymentMethod,
    required String occurredAt,
  }) async {
    // 1. 生成/读取主键
    // 2. 更新时保留未传入字段；新建写入默认支付方式
    final now = DateTime.now().toIso8601String();
    final txId = id ?? createId();
    final existing = id == null
        ? null
        : await (_db.select(_db.transactions)..where((t) => t.id.equals(txId)))
            .getSingleOrNull();
    final method = paymentMethod ??
        existing?.paymentMethod ??
        defaultPaymentMethod;

    if (existing != null) {
      await (_db.update(_db.transactions)..where((t) => t.id.equals(txId)))
          .write(
        TransactionsCompanion(
          type: Value(type.value),
          amount: Value(amount),
          category: Value(category),
          note: Value(note ?? ''),
          paymentMethod: Value(method),
          occurredAt: Value(occurredAt),
          updatedAt: Value(now),
        ),
      );
    } else {
      await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              id: txId,
              type: type.value,
              amount: amount,
              category: category,
              note: Value(note ?? ''),
              paymentMethod: Value(method),
              occurredAt: occurredAt,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    return txId;
  }

  Future<void> remove(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  Future<MonthSummary> monthSummary(String ym) async {
    final range = monthRange(ym);
    final row = await _db.customSelect(
      '''
      SELECT
        COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS income,
        COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS expense
      FROM transactions
      WHERE occurred_at >= ? AND occurred_at <= ?
      ''',
      variables: [Variable.withString(range.start), Variable.withString(range.end)],
      readsFrom: {_db.transactions},
    ).getSingle();
    final income = row.read<double>('income');
    final expense = row.read<double>('expense');
    return MonthSummary(income: income, expense: expense, balance: income - expense);
  }

  Future<List<CategoryAgg>> categoryAgg(
    String ym, {
    TxType type = TxType.expense,
  }) async {
    final range = monthRange(ym);
    final rows = await _db.customSelect(
      '''
      SELECT category, COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE type = ? AND occurred_at >= ? AND occurred_at <= ?
      GROUP BY category
      ORDER BY total DESC
      ''',
      variables: [
        Variable.withString(type.value),
        Variable.withString(range.start),
        Variable.withString(range.end),
      ],
      readsFrom: {_db.transactions},
    ).get();
    return rows
        .map(
          (r) => CategoryAgg(
            category: r.read<String>('category'),
            total: r.read<double>('total'),
          ),
        )
        .toList();
  }

  Future<List<DayTrend>> dayTrend(String ym) async {
    final range = monthRange(ym);
    final rows = await _db.customSelect(
      '''
      SELECT
        occurred_at AS day,
        COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS income,
        COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS expense
      FROM transactions
      WHERE occurred_at >= ? AND occurred_at <= ?
      GROUP BY occurred_at
      ORDER BY occurred_at ASC
      ''',
      variables: [Variable.withString(range.start), Variable.withString(range.end)],
      readsFrom: {_db.transactions},
    ).get();
    return rows
        .map(
          (r) => DayTrend(
            day: r.read<String>('day'),
            income: r.read<double>('income'),
            expense: r.read<double>('expense'),
          ),
        )
        .toList();
  }

  Future<void> clearAll() async {
    await _db.delete(_db.transactions).go();
  }
}

List<DayGroup> groupByDay(List<LedgerTransaction> list) {
  final map = <String, List<LedgerTransaction>>{};
  for (final item in list) {
    map.putIfAbsent(item.occurredAt, () => []).add(item);
  }
  return map.entries.map((e) => DayGroup(date: e.key, items: e.value)).toList();
}
