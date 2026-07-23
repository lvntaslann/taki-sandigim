class PersonTotal {
  const PersonTotal({required this.name, required this.totalTl});

  final String name;
  final double totalTl;
}

class BudgetSummary {
  const BudgetSummary({
    required this.totalReceivedTl,
    required this.totalGivenTl,
  });

  final double totalReceivedTl;
  final double totalGivenTl;

  double get netBalanceTl => totalReceivedTl - totalGivenTl;

  static const empty = BudgetSummary(totalReceivedTl: 0, totalGivenTl: 0);
}
