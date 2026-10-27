import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

class DateFormatter {
  DateFormatter._();

  // Locale-less formats follow Intl.defaultLocale, which main.dart keeps in
  // sync with the app language ("27 Ekim 2026" / "October 27, 2026").
  static String dayMonthYear(DateTime date) =>
      DateFormat.yMMMMd().format(date);

  static String shortDate(DateTime date) => DateFormat.yMd().format(date);

  static String remainingDays(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (diff == 0) return l10n.today;
    if (diff == 1) return l10n.tomorrow;
    if (diff < 0) return l10n.daysAgo(-diff);
    return l10n.daysLater(diff);
  }
}
