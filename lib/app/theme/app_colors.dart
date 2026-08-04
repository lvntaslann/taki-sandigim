import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFD89E30);
  static const Color primaryDark = Color(0xFFA67926);
  static const Color secondary = Color(0xFF463219);
  static const Color background = Color(0xFFFCF3E7);
  static const Color accent = Color(0xFFA67926);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2E7D32);
  static const Color textMuted = Color(0xFF736757);
  static const Color textMutedDark = Color(0xFFD6CCBC);
  static const Color cream = Color(0xFFFFEBD1);

  /// Muted/secondary text color that stays legible on both the light
  /// (cream) and dark backgrounds. [textMuted] alone is a brown-gray tuned
  /// for the light background and reads as low-contrast on dark surfaces.
  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? textMutedDark
      : textMuted;
}
