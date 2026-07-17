import 'package:hive/hive.dart';

import 'box_names.dart';

class UserSettingsRepository {
  static const _nameKey = 'user_name';

  Box get _box => Hive.box(BoxNames.settings);

  String? getName() => _box.get(_nameKey) as String?;

  Future<void> setName(String name) => _box.put(_nameKey, name);
}
