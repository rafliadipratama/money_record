import 'package:intl/intl.dart';

/// Formatter for financial amounts with Indonesian Rupiah locale by default.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Standard currency formatting: e.g. Rp 1.500.000
  static String format(double amount) {
    return _rupiahFormat.format(amount);
  }

  /// Signed currency formatting: e.g. + Rp 1.500.000 or - Rp 25.000
  static String formatSigned(double amount, {bool isExpense = false}) {
    final formatted = format(amount.abs());
    if (amount == 0) return formatted;
    return isExpense ? '- $formatted' : '+ $formatted';
  }

  /// Compact formatting for small chart labels: e.g. "1.5 jt", "500 rb"
  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} M';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} rb';
    }
    return amount.toStringAsFixed(0);
  }
}
