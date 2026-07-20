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

  static Map<GiftType, double> breakdownByType(List<GiftModel> gifts) {
    final breakdown = <GiftType, double>{};
    for (final gift in gifts) {
      if (gift.direction != GiftDirection.received) continue;
      breakdown[gift.giftType] =
          (breakdown[gift.giftType] ?? 0) + gift.estimatedValueTl;
    }
    return breakdown;
  }
}
