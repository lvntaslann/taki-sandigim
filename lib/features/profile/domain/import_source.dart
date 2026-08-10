enum ImportSource {
  excel,
  pdf;

  String get label => switch (this) {
        ImportSource.excel => 'Excel Dosyası',
        ImportSource.pdf => 'PDF Dosyası',
      };
}
