import 'package:hive/hive.dart';

import '../../../../core/database/box_names.dart';
import '../models/gift_enums.dart';
import '../models/gift_model.dart';

class GiftRepository {
  Box<GiftModel> get _box => Hive.box<GiftModel>(BoxNames.gifts);

  List<GiftModel> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<GiftModel> getByWedding(String weddingId) =>
      getAll().where((g) => g.weddingId == weddingId).toList();

  List<GiftModel> getByPerson(String personName) => getAll()
      .where((g) => g.personName.toLowerCase() == personName.toLowerCase())
      .toList();

  List<GiftModel> getByDirection(GiftDirection direction) =>
      getAll().where((g) => g.direction == direction).toList();

  Future<void> save(GiftModel gift) => _box.put(gift.id, gift);

  Future<void> delete(String id) => _box.delete(id);

  Future<void> clearAll() => _box.clear();
}
