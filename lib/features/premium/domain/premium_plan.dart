class PremiumPlan {
  const PremiumPlan({
    required this.id,
    required this.label,
    required this.months,
    required this.totalPriceTl,
    this.badge,
  });

  final String id;
  final String label;
  final int months;
  final double totalPriceTl;

  /// e.g. "En Avantajlı" — shown as a small tag on the plan card.
  final String? badge;

  double get monthlyEquivalentTl => totalPriceTl / months;

  /// Discount vs. paying the monthly plan repeatedly for the same period.
  double discountPercent(double monthlyPlanPriceTl) {
    final fullPrice = monthlyPlanPriceTl * months;
    if (fullPrice <= 0) return 0;
    return (1 - (totalPriceTl / fullPrice)) * 100;
  }

  static const List<PremiumPlan> all = [
    PremiumPlan(id: 'monthly', label: 'Aylık', months: 1, totalPriceTl: 9.99),
    PremiumPlan(id: 'quarterly', label: '3 Aylık', months: 3, totalPriceTl: 24.99),
    PremiumPlan(id: 'semiAnnual', label: '6 Aylık', months: 6, totalPriceTl: 39.99),
    PremiumPlan(
      id: 'annual',
      label: 'Yıllık',
      months: 12,
      totalPriceTl: 59.99,
      badge: 'En Avantajlı',
    ),
  ];
}
