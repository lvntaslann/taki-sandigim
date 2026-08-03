import 'package:hive/hive.dart';

import '../../features/dashboard/data/models/gift_enums.dart';
import 'box_names.dart';

class UserSettingsRepository {
  static const _nameKey = 'user_name';
  static const _darkModeKey = 'dark_mode';
  static const _notificationsKey = 'notifications_enabled';
  static const _emailKey = 'user_email';
  static const _photoKey = 'user_photo_base64';

  Box get _box => Hive.box(BoxNames.settings);

  String? getName() => _box.get(_nameKey) as String?;

  Future<void> setName(String name) => _box.put(_nameKey, name);

  bool isDarkMode() => _box.get(_darkModeKey, defaultValue: false) as bool;

  Future<void> setDarkMode(bool value) => _box.put(_darkModeKey, value);

  bool areNotificationsEnabled() =>
      _box.get(_notificationsKey, defaultValue: false) as bool;

  Future<void> setNotificationsEnabled(bool value) =>
      _box.put(_notificationsKey, value);

  String? getEmail() => _box.get(_emailKey) as String?;

  Future<void> setEmail(String email) => _box.put(_emailKey, email);

  String _eventDateKey(EventType eventType) => 'event_date_${eventType.name}';

  DateTime? getEventDate(EventType eventType) {
    final millis = _box.get(_eventDateKey(eventType)) as int?;
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> setEventDate(EventType eventType, DateTime date) =>
      _box.put(_eventDateKey(eventType), date.millisecondsSinceEpoch);

  String? getPhotoBase64() => _box.get(_photoKey) as String?;

  Future<void> setPhotoBase64(String base64) => _box.put(_photoKey, base64);

  Future<void> clearPhoto() => _box.delete(_photoKey);

  Future<void> clearAll() => _box.clear();
}
