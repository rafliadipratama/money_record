import 'package:intl/intl.dart';

/// Date utility helpers for friendly financial views and monthly buckets.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy', 'id_ID');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  /// Returns friendly relative date: "Hari Ini", "Kemarin", or formatted date.
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Kemarin';

    return _shortDateFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Returns start of month timestamp (e.g. 2026-10-01 00:00:00)
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Returns end of month timestamp (e.g. 2026-10-31 23:59:59.999)
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Checks if two dates fall on the exact same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns formatted full day name and date: "Minggu, 11 Oktober 2026"
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }
}
