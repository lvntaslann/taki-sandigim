import '../data/models/gift_enums.dart';
import '../data/models/gift_model.dart';
import 'budget_summary.dart';

class BudgetCalculator {
  BudgetCalculator._();

  static BudgetSummary calculate(List<GiftModel> gifts) {
    double received = 0;
    double given = 0;

    for (final gift in gifts) {
      if (gift.direction == GiftDirection.received) {
        received += gift.estimatedValueTl;
      } else {
        given += gift.estimatedValueTl;
      }
    }

    return BudgetSummary(totalReceivedTl: received, totalGivenTl: given);
  }

  static Map<GiftType, double> breakdownByType(
    List<GiftModel> gifts, {
    GiftDirection direction = GiftDirection.received,
  }) {
    final breakdown = <GiftType, double>{};
    for (final gift in gifts) {
      if (gift.direction != direction) continue;
      breakdown[gift.giftType] =
          (breakdown[gift.giftType] ?? 0) + gift.estimatedValueTl;
    }
    return breakdown;
  }

  static Map<GiftType, double> breakdownByTypeCombined(List<GiftModel> gifts) {
    final breakdown = <GiftType, double>{};
    for (final gift in gifts) {
      breakdown[gift.giftType] =
          (breakdown[gift.giftType] ?? 0) + gift.estimatedValueTl;
    }
    return breakdown;
  }

  static List<PersonTotal> groupByPerson(
    List<GiftModel> gifts,
    GiftDirection direction,
  ) {
    final totals = <String, double>{};
    for (final gift in gifts) {
      if (gift.direction != direction) continue;
      totals[gift.personName] =
          (totals[gift.personName] ?? 0) + gift.estimatedValueTl;
    }
    final list =
        totals.entries
            .map((e) => PersonTotal(name: e.key, totalTl: e.value))
            .toList()
          ..sort((a, b) => b.totalTl.compareTo(a.totalTl));
    return list;
  }
}
