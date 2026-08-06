import '../../dashboard/data/models/gift_enums.dart';

class GiftTypeGuesser {
  GiftTypeGuesser._();

  static GiftType guess(String text) {
    final m = text.toLowerCase();
    if (m.contains('çeyrek') || m.contains('ceyrek')) return GiftType.quarterGold;
    if (m.contains('yarım') || m.contains('yarim')) return GiftType.halfGold;
    if (m.contains('tam altın') || m.contains('tam altin')) {
      return GiftType.fullGold;
    }
    if (m.contains('gremse')) return GiftType.gremseGold;
    if (m.contains('gram')) return GiftType.gramGold;
    if (m.contains('bilezik')) return GiftType.bracelet;
    if (m.contains('kolye')) return GiftType.necklace;
    if (guessCurrencyCode(text) != null) return GiftType.cash;
    if (m.contains('lira') || m.contains(' tl') || m.contains('₺')) {
      return GiftType.cash;
    }
    return GiftType.other;
  }

  /// Foreign currency referenced in the text (e.g. "200 EURO" -> "EUR"), or
  /// null if it's plain TL/unrecognized.
  static String? guessCurrencyCode(String text) {
    final m = text.toLowerCase();
    if (m.contains('euro') || m.contains('eur') || m.contains('€')) return 'EUR';
    if (m.contains('dolar') || m.contains('usd') || m.contains(r'$')) return 'USD';
    if (m.contains('sterlin') || m.contains('gbp') || m.contains('£')) return 'GBP';
    return null;
  }
}
