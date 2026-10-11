import 'package:flutter_test/flutter_test.dart';
import 'package:money_record/core/math/expression_evaluator.dart';

void main() {
  group('ExpressionEvaluator', () {
    test('evaluates simple addition and subtraction', () {
      expect(ExpressionEvaluator.evaluate('15000 + 25000'), 40000.0);
      expect(ExpressionEvaluator.evaluate('50000 - 15000'), 35000.0);
    });

    test('respects operator precedence (* and / over + and -)', () {
      expect(ExpressionEvaluator.evaluate('10 + 20 * 3'), 70.0);
      expect(ExpressionEvaluator.evaluate('100 - 40 / 2'), 80.0);
      expect(ExpressionEvaluator.evaluate('10 + 20 × 3'), 70.0);
    });

    test('handles parentheses correctly', () {
      expect(ExpressionEvaluator.evaluate('(10 + 20) * 3'), 90.0);
      expect(ExpressionEvaluator.evaluate('((5 + 5) * 2) / 4'), 5.0);
    });

    test('handles decimals and unary minus', () {
      expect(ExpressionEvaluator.evaluate('10.5 + 4.5'), 15.0);
      expect(ExpressionEvaluator.evaluate('-10 + 50'), 40.0);
    });

    test('throws UnsupportedError on division by zero', () {
      expect(
        () => ExpressionEvaluator.evaluate('100 / 0'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('returns 0 for empty or whitespace expressions', () {
      expect(ExpressionEvaluator.evaluate(''), 0.0);
      expect(ExpressionEvaluator.evaluate('   '), 0.0);
    });
  });
}
