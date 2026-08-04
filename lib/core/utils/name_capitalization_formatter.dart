import 'package:flutter/services.dart';

/// Capitalizes the first letter of each word as the user types,
/// e.g. "ayşe yılmaz" -> "Ayşe Yılmaz".
class NameCapitalizationFormatter extends TextInputFormatter {
  const NameCapitalizationFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    var capitalizeNext = true;
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char.trim().isEmpty) {
        buffer.write(char);
        capitalizeNext = true;
      } else if (capitalizeNext) {
        buffer.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        buffer.write(char);
      }
    }

    final formatted = buffer.toString();
    if (formatted == text) return newValue;

    return newValue.copyWith(
      text: formatted,
      selection: newValue.selection,
    );
  }
}
