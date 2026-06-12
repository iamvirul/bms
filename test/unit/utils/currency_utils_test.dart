import 'package:bms/core/utils/currency_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyUtils', () {
    group('applyDiscount', () {
      test('returns original amount when discount is zero', () {
        expect(CurrencyUtils.applyDiscount(100, 0), 100.0);
      });

      test('returns zero when discount is 100%', () {
        expect(CurrencyUtils.applyDiscount(100, 100), 0.0);
      });

      test('rounds to two decimal places', () {
        expect(CurrencyUtils.applyDiscount(100, 33), 67.0);
      });
    });

    group('marginPercent', () {
      test('returns zero when sell price is zero', () {
        expect(CurrencyUtils.marginPercent(50, 0), 0.0);
      });

      test('calculates correct gross margin', () {
        expect(CurrencyUtils.marginPercent(60, 100), 40.0);
      });
    });
  });
}
