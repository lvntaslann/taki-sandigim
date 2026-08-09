import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../dashboard/data/models/gift_enums.dart';
import '../../dashboard/data/models/gift_model.dart';
import '../../dashboard/data/repositories/gift_repository.dart';

/// Thrown when the picked file's header row doesn't match the app's export format.
class GiftImportFormatException implements Exception {
  GiftImportFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GiftImportResult {
  const GiftImportResult({required this.addedCount});

  final int addedCount;
}

class GiftImportService {
  GiftImportService(this._repository);

  final GiftRepository _repository;

  static const _expectedHeaders = [
    'Tarih',
    'Kişi',
    'Hediye',
    'Miktar',
    'Değer (TL)',
    'Yön',
  ];

  final _dateFormat = DateFormat('d MMM y', 'tr_TR');
  final _uuid = const Uuid();

  /// Opens a file picker for .xlsx files, validates the format, parses valid
  /// rows and appends them to the existing gift list. Duplicate rows (same
  /// date + person name + amount as an existing record) are skipped.
  ///
  /// Returns null if the user cancelled the file picker.
  Future<GiftImportResult?> pickAndImport() async {
    final pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    final bytes = pickerResult?.files.single.bytes;
    if (bytes == null) return null;

    final workbook = xls.Excel.decodeBytes(bytes);
    if (workbook.tables.isEmpty) {
      throw GiftImportFormatException('Dosyada okunabilir bir sayfa bulunamadı.');
    }
    // Prefer the sheet our own export writes to; workbooks may also contain
    // an empty default sheet (e.g. "Sheet1") alongside it.
    final sheet = workbook.tables['Takı Listem'] ??
        workbook.tables.values.firstWhere(
          (table) => table.rows.isNotEmpty,
          orElse: () => workbook.tables.values.first,
        );
    final rows = sheet.rows;
    if (rows.isEmpty) {
      throw GiftImportFormatException('Dosya boş.');
    }

    final headerCells = rows.first
        .map((cell) => cell?.value?.toString().trim() ?? '')
        .toList();
    if (headerCells.length < _expectedHeaders.length ||
        !_expectedHeaders.every(
          (expected) => headerCells.contains(expected),
        )) {
      throw GiftImportFormatException(
        'Bu dosya Takı Sandığım formatında değil. Lütfen uygulamadan '
        'dışa aktarılmış bir Excel dosyası seçin.',
      );
    }
    final columnIndex = {
      for (final header in _expectedHeaders) header: headerCells.indexOf(header),
    };

    final existing = _repository.getAll();
    final existingKeys = existing.map(_keyFor).toSet();

    var addedCount = 0;
    for (final row in rows.skip(1)) {
      final gift = _parseRow(row, columnIndex);
      if (gift == null) continue;
      final key = _keyFor(gift);
      if (existingKeys.contains(key)) continue;

      await _repository.save(gift);
      existingKeys.add(key);
      addedCount++;
    }

    return GiftImportResult(addedCount: addedCount);
  }

  GiftModel? _parseRow(List<xls.Data?> row, Map<String, int> columnIndex) {
    String textAt(String header) {
      final index = columnIndex[header]!;
      if (index >= row.length) return '';
      return row[index]?.value?.toString().trim() ?? '';
    }

    final dateText = textAt('Tarih');
    final personName = textAt('Kişi');
    final giftLabel = textAt('Hediye');
    final amountText = textAt('Miktar');
    final valueText = textAt('Değer (TL)');
    final directionLabel = textAt('Yön');

    if (personName.isEmpty) return null;

    final date = _tryParseDate(dateText);
    if (date == null) return null;

    final giftType = _giftTypeFromLabel(giftLabel);
    if (giftType == null) return null;

    final direction = _directionFromLabel(directionLabel);
    if (direction == null) return null;

    final amount = double.tryParse(amountText.replaceAll(',', '.'));
    if (amount == null) return null;

    final estimatedValueTl = double.tryParse(valueText.replaceAll(',', '.'));
    if (estimatedValueTl == null) return null;

    return GiftModel(
      id: _uuid.v4(),
      personName: personName,
      giftType: giftType,
      amount: amount,
      estimatedValueTl: estimatedValueTl,
      direction: direction,
      date: date,
    );
  }

  DateTime? _tryParseDate(String text) {
    if (text.isEmpty) return null;
    try {
      return _dateFormat.parse(text);
    } catch (_) {
      return null;
    }
  }

  GiftType? _giftTypeFromLabel(String label) {
    for (final type in GiftType.values) {
      if (type.label == label) return type;
    }
    return null;
  }

  GiftDirection? _directionFromLabel(String label) {
    for (final direction in GiftDirection.values) {
      if (direction.label == label) return direction;
    }
    return null;
  }

  /// Key used for duplicate detection: same date + person + amount.
  String _keyFor(GiftModel gift) =>
      '${_dateFormat.format(gift.date)}|${gift.personName.toLowerCase()}|${gift.amount}';
}
