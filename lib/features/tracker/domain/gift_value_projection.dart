import '../../dashboard/data/models/gift_model.dart';

class ValuePoint {
  const ValuePoint({required this.date, required this.valueTl});

  final DateTime date;
  final double valueTl;
}

enum ValueProjectionRange { day, week, month, year, all }

extension ValueProjectionRangeLabel on ValueProjectionRange {
  String get label {
    switch (this) {
      case ValueProjectionRange.day:
        return 'Gün';
      case ValueProjectionRange.week:
        return 'Hafta';
      case ValueProjectionRange.month:
        return 'Ay';
      case ValueProjectionRange.year:
        return 'Yıl';
      case ValueProjectionRange.all:
        return 'Tümü';
    }
  }

  Duration? get duration {
    switch (this) {
      case ValueProjectionRange.day:
        return const Duration(days: 1);
      case ValueProjectionRange.week:
        return const Duration(days: 7);
      case ValueProjectionRange.month:
        return const Duration(days: 30);
      case ValueProjectionRange.year:
        return const Duration(days: 365);
      case ValueProjectionRange.all:
        return null;
    }
  }
}

/// Estimates how a gift's value has changed from the day it was recorded
/// to today. Only the entry-day value and the current value are real; the
/// points in between are a straight-line interpolation used purely to draw
/// a trend, since the app has no historical rate feed to draw from.
///
/// Because the trend is a straight line between exactly two real anchors,
/// picking a shorter [ValueProjectionRange] doesn't reveal extra real
/// fluctuation — it only changes which portion of that same line is shown,
/// evaluated honestly at each date via [valueAt].
class GiftValueProjection {
  const GiftValueProjection({
    required this.entryDate,
    required this.now,
    required this.entryValueTl,
    required this.currentValueTl,
  });

  final DateTime entryDate;
  final DateTime now;
  final double entryValueTl;
  final double currentValueTl;

  double get changePercent {
    if (entryValueTl == 0) return 0;
    return (currentValueTl - entryValueTl) / entryValueTl * 100;
  }

  bool get isIncrease => currentValueTl >= entryValueTl;

  double valueAt(DateTime date) {
    final totalMs = now.difference(entryDate).inMilliseconds;
    if (totalMs <= 0) return currentValueTl;
    final elapsedMs = date
        .difference(entryDate)
        .inMilliseconds
        .clamp(0, totalMs);
    return entryValueTl + (currentValueTl - entryValueTl) * (elapsedMs / totalMs);
  }

  List<ValuePoint> seriesFor(ValueProjectionRange range) {
    final duration = range.duration;
    final windowStart = duration == null
        ? entryDate
        : (now.subtract(duration).isBefore(entryDate)
              ? entryDate
              : now.subtract(duration));

    final totalDays = now.difference(windowStart).inDays.clamp(1, 100000);
    final stepCount = totalDays > 365
        ? 12
        : (totalDays > 30 ? 8 : (totalDays > 7 ? 6 : 4));

    return [
      for (var i = 0; i <= stepCount; i++)
        ValuePoint(
          date: windowStart.add(
            Duration(days: (totalDays * i / stepCount).round()),
          ),
          valueTl: valueAt(
            windowStart.add(
              Duration(days: (totalDays * i / stepCount).round()),
            ),
          ),
        ),
    ];
  }

  static GiftValueProjection build({
    required GiftModel gift,
    required double currentValueTl,
  }) {
    return GiftValueProjection(
      entryDate: gift.date,
      now: DateTime.now(),
      entryValueTl: gift.estimatedValueTl,
      currentValueTl: currentValueTl,
    );
  }
}
