import '../../dashboard/data/models/gift_enums.dart';
import '../../dashboard/data/models/gift_model.dart';
import 'balance_status.dart';

class BalanceAnalyzer {
  BalanceAnalyzer._();

  static List<BalanceStatus> calculate(List<GiftModel> gifts) {
    final Map<String, double> received = {};
    final Map<String, double> given = {};

    for (final gift in gifts) {
      final person = gift.personName.trim();
      if (person.isEmpty) continue;

      if (gift.direction == GiftDirection.received) {
        received[person] = (received[person] ?? 0) + gift.estimatedValueTl;
      } else {
        given[person] = (given[person] ?? 0) + gift.estimatedValueTl;
      }
    }

    final allPeople = {...received.keys, ...given.keys};

    final result = allPeople
        .map(
          (person) => BalanceStatus(
            personName: person,
            receivedTl: received[person] ?? 0,
            givenTl: given[person] ?? 0,
          ),
        )
        .toList();

    result.sort((a, b) => b.balanceTl.abs().compareTo(a.balanceTl.abs()));
    return result;
  }
}
