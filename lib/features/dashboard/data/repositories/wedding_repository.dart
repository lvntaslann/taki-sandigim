import 'package:hive/hive.dart';

import '../../../../core/database/box_names.dart';
import '../models/wedding_model.dart';

class WeddingRepository {
  Box<WeddingModel> get _box => Hive.box<WeddingModel>(BoxNames.weddings);

  List<WeddingModel> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<WeddingModel> getUpcoming({DateTime? now}) {
    final today = now ?? DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return getAll().where((w) => !w.date.isBefore(startOfToday)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  WeddingModel? getById(String id) {
    try {
      return _box.values.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(WeddingModel wedding) => _box.put(wedding.id, wedding);

  Future<void> delete(String id) => _box.delete(id);

  Future<void> clearAll() => _box.clear();
}
