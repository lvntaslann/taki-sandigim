import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:taki_sandigim/features/dashboard/data/models/gift_enums.dart';
import 'package:taki_sandigim/features/profile/data/gift_export_service.dart';
import 'package:taki_sandigim/l10n/app_localizations.dart';

/// Exports are written in the app language and imported in any language, so
/// the Turkish strings must stay identical to the pre-localization format.
void main() {
  final tr = lookupAppLocalizations(const Locale('tr'));
  final en = lookupAppLocalizations(const Locale('en'));

  setUpAll(() async {
    await initializeDateFormatting('tr');
    await initializeDateFormatting('en');
  });

  test('Turkish export format matches files exported before localization', () {
    expect(GiftExportService.dateFormatFor(tr).pattern, 'd MMM y');
    expect(GiftExportService.giftHeaders(tr), [
      'Tarih', 'Kişi', 'Hediye', 'Miktar', 'Birim', 'Değer (TL)', 'Yön',
    ]);
    expect(GiftExportService.weddingHeaders(tr), ['Başlık', 'Tarih', 'Konum', 'Not']);
    expect(tr.exportSheetGifts, 'Takı Listem');
    expect(tr.exportSheetWeddings, 'Davetiye Bilgileri');
    expect(
      {for (final t in GiftType.values) t: t.localizedLabel(tr)},
      {
        GiftType.quarterGold: 'Çeyrek Altın',
        GiftType.halfGold: 'Yarım Altın',
        GiftType.fullGold: 'Tam Altın',
        GiftType.gremseGold: 'Gremse Altın',
        GiftType.bracelet: 'Bilezik',
        GiftType.necklace: 'Kolye',
        GiftType.cash: 'Para',
        GiftType.other: 'Diğer',
        GiftType.gramGold: 'Gram Altın',
      },
    );
    expect(GiftDirection.received.localizedLabel(tr), 'Bize Takılan');
    expect(GiftDirection.given.localizedLabel(tr), 'Bizim Taktığımız');
  });

  for (final l10n in [tr, en]) {
    test('${l10n.localeName} dates and labels round-trip', () {
      final date = DateTime(2026, 10, 27);
      final format = GiftExportService.dateFormatFor(l10n);
      expect(format.parse(format.format(date)), date);

      final typeLabels = GiftType.values.map((t) => t.localizedLabel(l10n));
      expect(typeLabels.toSet(), hasLength(GiftType.values.length));
      final directionLabels = GiftDirection.values.map((d) => d.localizedLabel(l10n));
      expect(directionLabels.toSet(), hasLength(GiftDirection.values.length));
    });
  }
}
