class InvitationInfo {
  const InvitationInfo({
    required this.title,
    this.date,
    this.time,
    this.location,
  });

  final String title;
  final DateTime? date;

  /// e.g. "19:00" — kept as free text since the AI may not always return a
  /// strict HH:mm value.
  final String? time;
  final String? location;
}
