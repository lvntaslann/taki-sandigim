import '../../features/dashboard/data/models/gift_enums.dart';

class CurrencyConverter {
  CurrencyConverter._();

  static double giftValueTl({
    required GiftType giftType,
    required double amount,
    required double goldRateTl,
  }) {
    if (giftType.gramEquivalent > 0) {
      return amount * giftType.gramEquivalent * goldRateTl;
    }
    if (giftType == GiftType.cash) return amount;
    return amount * goldRateTl;
  }

  static String formatTl(double value) {
    return '${value.toStringAsFixed(0)} ₺';
  }
}
