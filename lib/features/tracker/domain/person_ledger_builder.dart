import '../../dashboard/data/models/gift_model.dart';
import 'balance_analyzer.dart';
import 'person_ledger.dart';

class PersonLedgerBuilder {
  PersonLedgerBuilder._();

  static List<PersonLedger> build(List<GiftModel> allEntries) {
    final Map<String, List<GiftModel>> grouped = {};
    for (final entry in allEntries) {
      final person = entry.personName.trim();
      if (person.isEmpty) continue;
      grouped.putIfAbsent(person, () => []).add(entry);
    }

    final statuses = BalanceAnalyzer.calculate(allEntries);
    final statusByPerson = {for (final s in statuses) s.personName: s};

    final result = grouped.entries.map((entry) {
      final entries = entry.value..sort((a, b) => b.date.compareTo(a.date));
      return PersonLedger(
        personName: entry.key,
        entries: entries,
        status: statusByPerson[entry.key]!,
      );
    }).toList();

    result.sort((a, b) {
      final aDate = a.entries.first.date;
      final bDate = b.entries.first.date;
      return bDate.compareTo(aDate);
    });

    return result;
  }
}
