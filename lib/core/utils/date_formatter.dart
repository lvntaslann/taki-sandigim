import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String dayMonthYear(DateTime date) =>
      DateFormat('d MMMM yyyy', 'tr_TR').format(date);

  static String shortDate(DateTime date) =>
      DateFormat('dd.MM.yyyy', 'tr_TR').format(date);

  static String remainingDays(DateTime date) {
    final now = DateTime.now();
    final diff = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (diff == 0) return 'Bugün';
    if (diff == 1) return 'Yarın';
    if (diff < 0) return '${-diff} gün önce';
    return '$diff gün sonra';
  }
}
