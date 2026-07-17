import '../../dashboard/data/models/gift_enums.dart';
import '../../dashboard/data/models/gift_model.dart';
import 'balance_status.dart';

class PersonLedger {
  const PersonLedger({
    required this.personName,
    required this.entries,
    required this.status,
  });

  final String personName;
  final List<GiftModel> entries;
  final BalanceStatus status;

  GiftModel? get lastReceived =>
      entries.where((e) => e.direction == GiftDirection.received).firstOrNull;

  GiftModel? get lastGiven =>
      entries.where((e) => e.direction == GiftDirection.given).firstOrNull;
}

extension on Iterable<GiftModel> {
  GiftModel? get firstOrNull => isEmpty ? null : first;
}
