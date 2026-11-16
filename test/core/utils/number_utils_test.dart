import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/utils/number_utils.dart';

void main() {
  test('formatDecimal', () {
    expect(formatDecimal(150.0), '150');
    expect(formatDecimal(150.5), '150.5');
    expect(formatDecimal(1500), '1,500');
    expect(formatDecimal(null), '');
  });

  test('formatPercentage', () {
    expect(formatPercentage(20.0), '20%');
    expect(formatPercentage(12.5), '12.5%');
    expect(formatPercentage(null), '');
  });

  test('truncateToDecimal truncates, not rounds', () {
    expect(truncateToDecimal(4.68, 1), 4.6);
    expect(truncateToDecimal(4.99, 0), 4.0);
    expect(truncateToDecimal(3.456, 2), 3.45);
  });

  test('formatDecimalString', () {
    expect(formatDecimalString('150.0'), '150');
    expect(formatDecimalString('150.5'), '150.5');
    expect(formatDecimalString('abc'), 'abc');
    expect(formatDecimalString(null), '');
  });
}
