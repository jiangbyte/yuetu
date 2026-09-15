import 'package:flutter_test/flutter_test.dart';

import 'package:yuetu/core/utils/date.dart';
import 'package:yuetu/core/utils/money.dart';

void main() {
  test('formatMoney keeps two decimals', () {
    expect(formatMoney(12.5), '12.50');
    expect(formatMoney(1000), '1,000.00');
  });

  test('signedMoney prefixes by type', () {
    expect(signedMoney('income', 10), '+10.00');
    expect(signedMoney('expense', 10), '-10.00');
  });

  test('monthRange covers full month', () {
    final range = monthRange('2026-02');
    expect(range.start, '2026-02-01');
    expect(range.end, '2026-02-28');
  });

  test('shiftYearMonth wraps year', () {
    expect(shiftYearMonth('2025-12', 1), '2026-01');
    expect(shiftYearMonth('2026-01', -1), '2025-12');
  });
}
