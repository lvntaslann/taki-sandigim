import '../../../l10n/app_localizations.dart';

enum ImportSource {
  excel,
  pdf;

  String localizedLabel(AppLocalizations l10n) => switch (this) {
        ImportSource.excel => l10n.importSourceExcel,
        ImportSource.pdf => l10n.importSourcePdf,
      };
}
