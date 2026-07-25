import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../features/dashboard/data/models/gift_enums.dart';
import '../../features/dashboard/data/models/gift_model.dart';
import '../../features/dashboard/data/models/wedding_model.dart';
import 'box_names.dart';

class HiveService {
  HiveService._();

  static bool _initialized = false;
  static const Uuid _uuid = Uuid();

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

    await _seedSampleGiftsIfEmpty();

    _initialized = true;
  }

  static Future<void> _seedSampleGiftsIfEmpty() async {
    final box = Hive.box<GiftModel>(BoxNames.gifts);
    if (box.isNotEmpty) return;

    final now = DateTime.now();
    final sampleGifts = [
      GiftModel(
        id: _uuid.v4(),
        personName: 'Ayşe Kurt',
        giftType: GiftType.quarterGold,
        amount: 4,
        estimatedValueTl: 4280,
        direction: GiftDirection.received,
        date: now.subtract(const Duration(days: 20)),
        relationType: RelationType.family,
      ),
      GiftModel(
        id: _uuid.v4(),
        personName: 'Sümeyye Türk',
        giftType: GiftType.cash,
        amount: 2500,
        estimatedValueTl: 2500,
        direction: GiftDirection.received,
        date: now.subtract(const Duration(days: 15)),
        relationType: RelationType.friend,
      ),
      GiftModel(
        id: _uuid.v4(),
        personName: 'Zeynep Güngör',
        giftType: GiftType.bracelet,
        amount: 1,
        estimatedValueTl: 1850,
        direction: GiftDirection.received,
        date: now.subtract(const Duration(days: 10)),
        relationType: RelationType.relative,
      ),
      GiftModel(
        id: _uuid.v4(),
        personName: 'Ayşe Kurt',
        giftType: GiftType.other,
        amount: 1,
        estimatedValueTl: 1110,
        direction: GiftDirection.received,
        date: now.subtract(const Duration(days: 5)),
        relationType: RelationType.family,
      ),
      GiftModel(
        id: _uuid.v4(),
        personName: 'Zeynep Güngör',
        giftType: GiftType.quarterGold,
        amount: 6,
        estimatedValueTl: 6420,
        direction: GiftDirection.received,
        date: now.subtract(const Duration(days: 3)),
        relationType: RelationType.relative,
      ),
      GiftModel(
        id: _uuid.v4(),
        personName: 'Sümeyye Türk',
        giftType: GiftType.cash,
        amount: 2290,
        estimatedValueTl: 2290,
        direction: GiftDirection.received,
        date: now.subtract(const Duration(days: 1)),
        relationType: RelationType.friend,
      ),
    ];

    for (final gift in sampleGifts) {
      await box.put(gift.id, gift);
    }
  }
}
