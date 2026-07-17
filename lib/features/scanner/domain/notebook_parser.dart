import 'notebook_line.dart';

class NotebookParser {
  NotebookParser._();

  static final RegExp _separator = RegExp(r'[-:–—]');
  static final RegExp _amountRegex = RegExp(r'(\d+(?:[.,]\d+)?)');
  static final RegExp _nameLetters = RegExp(r'^[A-Za-zÇĞİıÖŞÜçğıöşü\s]+$');
  static final RegExp _anyLetter = RegExp(r'[A-Za-zÇĞİıÖŞÜçğıöşü]');

  static final RegExp _typeWord = RegExp(
    r'^(ceyrek|çeyrek|yarim|yarım|tam|gremse|bilezik|kolye|altin|altın|'
    r'lira|tl|₺|gram|gr|adet|para|nakit)\W*$',
    caseSensitive: false,
  );
  static final RegExp _numberWord = RegExp(r'^\d+([.,]\d+)?\W*$');

  static List<NotebookLine> parse(String rawText) {
    final lines = rawText
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);

    final result = <NotebookLine>[];

    for (final line in lines) {
      final parts = _separator.hasMatch(line)
          ? line.split(_separator)
          : _guessSplit(line);

      if (parts.length < 2) continue;

      final personName = parts.first.trim();
      final giftPart = parts.sublist(1).join(' ').trim();

      if (!_isValidName(personName) || !_isValidGift(giftPart)) continue;

      final amountMatch = _amountRegex.firstMatch(giftPart);
      final amount = amountMatch != null
          ? double.tryParse(amountMatch.group(1)!.replaceAll(',', '.'))
          : null;

      final giftDescription = giftPart
          .replaceAll(_amountRegex, '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      result.add(
        NotebookLine(
          personName: personName,
          giftDescription: giftDescription.isEmpty ? giftPart : giftDescription,
          amount: amount,
          rawText: line,
        ),
      );
    }

    return result;
  }

  static bool _isValidName(String name) {
    final trimmed = name.trim();
    if (trimmed.length < 2) return false;
    if (!_nameLetters.hasMatch(trimmed)) return false;

    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length == 1 && trimmed == trimmed.toUpperCase()) return false;
    return true;
  }

  static bool _isValidGift(String gift) {
    if (gift.trim().isEmpty) return false;
    return _anyLetter.hasMatch(gift);
  }

  static List<String> _guessSplit(String line) {
    final words = line.split(RegExp(r'\s+'));
    if (words.length < 2) return [line];

    for (var i = 1; i < words.length; i++) {
      final word = words[i];
      if (_typeWord.hasMatch(word) || _numberWord.hasMatch(word)) {
        final name = words.sublist(0, i).join(' ');
        final gift = words.sublist(i).join(' ');
        return [name, gift];
      }
    }

    if (words.length >= 3) {
      final name = words.sublist(0, words.length - 1).join(' ');
      final gift = words.last;
      return [name, gift];
    }

    return [line];
  }
}
