class BalanceStatus {
  const BalanceStatus({
    required this.personName,
    required this.receivedTl,
    required this.givenTl,
  });

  final String personName;
  final double receivedTl;
  final double givenTl;

  double get balanceTl => receivedTl - givenTl;

  bool get isBalanced => balanceTl.abs() < 1;
  bool get theyOweUs => balanceTl < 0;
  bool get weOwe => balanceTl > 0;
}
