import 'package:hive_flutter/hive_flutter.dart';

import '../../features/dashboard/data/models/gift_enums.dart';
import '../../features/dashboard/data/models/gift_model.dart';
import '../../features/dashboard/data/models/wedding_model.dart';
import 'box_names.dart';

class HiveService {
  HiveService._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    Hive.registerAdapter(WeddingModelAdapter());
    Hive.registerAdapter(GiftModelAdapter());
    Hive.registerAdapter(GiftTypeAdapter());
    Hive.registerAdapter(GiftDirectionAdapter());
    Hive.registerAdapter(RelationTypeAdapter());
    Hive.registerAdapter(EventTypeAdapter());

    await Future.wait([
      Hive.openBox<WeddingModel>(BoxNames.weddings),
      Hive.openBox<GiftModel>(BoxNames.gifts),
      Hive.openBox(BoxNames.settings),
    ]);

    await _removeLegacySampleGifts();

    _initialized = true;
  }

  /// One-time cleanup: earlier builds seeded the gifts box with sample
  /// entries (Ayşe Kurt, Sümeyye Türk, Zeynep Güngör) if it was empty.
  /// This removes any leftover entries matching that exact seed data.
  static Future<void> _removeLegacySampleGifts() async {
    final box = Hive.box<GiftModel>(BoxNames.gifts);
    final legacyFingerprints = {
      ('Ayşe Kurt', GiftType.quarterGold, 4280.0),
      ('Sümeyye Türk', GiftType.cash, 2500.0),
      ('Zeynep Güngör', GiftType.bracelet, 1850.0),
      ('Ayşe Kurt', GiftType.other, 1110.0),
      ('Zeynep Güngör', GiftType.quarterGold, 6420.0),
      ('Sümeyye Türk', GiftType.cash, 2290.0),
    };

    final keysToRemove = <dynamic>[];
    for (final key in box.keys) {
      final gift = box.get(key);
      if (gift == null) continue;
      final fingerprint = (gift.personName, gift.giftType, gift.estimatedValueTl);
      if (legacyFingerprints.contains(fingerprint)) {
        keysToRemove.add(key);
      }
    }
    if (keysToRemove.isNotEmpty) {
      await box.deleteAll(keysToRemove);
    }
  }
}
