class NotebookLine {
  const NotebookLine({
    required this.personName,
    required this.giftDescription,
    this.amount,
    this.rawText = '',
  });

  final String personName;
  final String giftDescription;
  final double? amount;
  final String rawText;
}
