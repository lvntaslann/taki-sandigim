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

    await Future.wait([
      Hive.openBox<WeddingModel>(BoxNames.weddings),
      Hive.openBox<GiftModel>(BoxNames.gifts),
      Hive.openBox(BoxNames.settings),
    ]);

    _initialized = true;
  }
}
