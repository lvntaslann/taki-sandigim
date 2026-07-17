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
    if (m.contains('bilezik')) return GiftType.bracelet;
    if (m.contains('kolye')) return GiftType.necklace;
    if (m.contains('lira') || m.contains(' tl') || m.contains('₺')) {
      return GiftType.cash;
    }
    return GiftType.other;
  }
}
