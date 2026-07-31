import 'package:flutter/material.dart';

import '../../core/database/user_settings_repository.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._(super.value);

  static final ThemeController instance = ThemeController._(
    UserSettingsRepository().isDarkMode() ? ThemeMode.dark : ThemeMode.light,
  );

  bool get isDark => value == ThemeMode.dark;

  Future<void> setDark(bool isDark) async {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
    await UserSettingsRepository().setDarkMode(isDark);
  }
}
