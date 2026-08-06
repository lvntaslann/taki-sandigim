enum ScanSource {
  notebook,
  invitation;

  String get label => switch (this) {
        ScanSource.notebook => 'Takı Defteri',
        ScanSource.invitation => 'Davetiye',
      };
}
