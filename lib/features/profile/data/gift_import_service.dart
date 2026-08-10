import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../dashboard/data/models/gift_enums.dart';
import '../../dashboard/data/models/gift_model.dart';
import '../../dashboard/data/models/wedding_model.dart';
import '../../dashboard/data/repositories/gift_repository.dart';
import '../../dashboard/data/repositories/wedding_repository.dart';

/// Thrown when the picked file's header row doesn't match the app's export format.
class GiftImportFormatException implements Exception {
  GiftImportFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GiftImportResult {
  const GiftImportResult({required this.addedCount, required this.addedWeddingCount});

  final int addedCount;
  final int addedWeddingCount;
}

class GiftImportService {
  GiftImportService(this._repository, {WeddingRepository? weddingRepository})
    : _weddingRepository = weddingRepository ?? WeddingRepository();

  final GiftRepository _repository;
  final WeddingRepository _weddingRepository;

  static const _expectedHeaders = [
    'Tarih',
    'Kişi',
    'Hediye',
    'Miktar',
    'Değer (TL)',
    'Yön',
  ];

  static const _expectedWeddingHeaders = ['Başlık', 'Tarih', 'Konum', 'Not'];

  final _dateFormat = DateFormat('d MMM y', 'tr_TR');
  final _uuid = const Uuid();

  /// Opens a file picker for .xlsx files, validates the format, and restores
  /// both the gift list ("Takı Listem" sheet) and the wedding/invitation
  /// records ("Davetiye Bilgileri" sheet) our own export writes. Duplicate
  /// rows are skipped (same date + person name + amount for gifts, same
  /// title + date for weddings).
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
      for (final header in headerCells) header: headerCells.indexOf(header),
    };

    final addedCount = await _importGifts(rows, columnIndex);
    final addedWeddingCount = await _importWeddings(workbook.tables['Davetiye Bilgileri']);

    return GiftImportResult(addedCount: addedCount, addedWeddingCount: addedWeddingCount);
  }

  Future<int> _importGifts(List<List<xls.Data?>> rows, Map<String, int> columnIndex) async {
    final existingKeys = _repository.getAll().map(_giftKeyFor).toSet();

    var addedCount = 0;
    for (final row in rows.skip(1)) {
      final gift = _parseGiftRow(row, columnIndex);
      if (gift == null) continue;
      final key = _giftKeyFor(gift);
      if (existingKeys.contains(key)) continue;

      await _repository.save(gift);
      existingKeys.add(key);
      addedCount++;
    }
    return addedCount;
  }

  Future<int> _importWeddings(xls.Sheet? sheet) async {
    if (sheet == null || sheet.rows.isEmpty) return 0;

    final headerCells = sheet.rows.first
        .map((cell) => cell?.value?.toString().trim() ?? '')
        .toList();
    if (!_expectedWeddingHeaders.every((expected) => headerCells.contains(expected))) {
      return 0;
    }
    final columnIndex = {
      for (final header in headerCells) header: headerCells.indexOf(header),
    };

    final existingKeys = _weddingRepository.getAll().map(_weddingKeyFor).toSet();

    var addedCount = 0;
    for (final row in sheet.rows.skip(1)) {
      final wedding = _parseWeddingRow(row, columnIndex);
      if (wedding == null) continue;
      final key = _weddingKeyFor(wedding);
      if (existingKeys.contains(key)) continue;

      await _weddingRepository.save(wedding);
      existingKeys.add(key);
      addedCount++;
    }
    return addedCount;
  }

  GiftModel? _parseGiftRow(List<xls.Data?> row, Map<String, int> columnIndex) {
    String textAt(String header) {
      final index = columnIndex[header];
      if (index == null || index >= row.length) return '';
      return row[index]?.value?.toString().trim() ?? '';
    }

    final dateText = textAt('Tarih');
    final personName = textAt('Kişi');
    final giftLabel = textAt('Hediye');
    final amountText = textAt('Miktar');
    final unitText = textAt('Birim');
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

    // "Birim" is only meaningful for cash gifts: 'TL', a foreign currency
    // code (e.g. 'USD'), or '-' for gold/other types.
    final isForeignCurrency =
        giftType == GiftType.cash && unitText.isNotEmpty && unitText != '-' && unitText != 'TL';
    final currencyCode = isForeignCurrency ? unitText : null;
    final currencyRateTl = isForeignCurrency && amount != 0 ? estimatedValueTl / amount : null;

    return GiftModel(
      id: _uuid.v4(),
      personName: personName,
      giftType: giftType,
      amount: amount,
      estimatedValueTl: estimatedValueTl,
      direction: direction,
      date: date,
      currencyCode: currencyCode,
      currencyRateTl: currencyRateTl,
    );
  }

  WeddingModel? _parseWeddingRow(List<xls.Data?> row, Map<String, int> columnIndex) {
    String textAt(String header) {
      final index = columnIndex[header];
      if (index == null || index >= row.length) return '';
      return row[index]?.value?.toString().trim() ?? '';
    }

    final title = textAt('Başlık');
    final dateText = textAt('Tarih');
    final location = textAt('Konum');
    final note = textAt('Not');

    if (title.isEmpty) return null;

    final date = _tryParseDate(dateText);
    if (date == null) return null;

    return WeddingModel(
      id: _uuid.v4(),
      title: title,
      date: date,
      location: location.isEmpty || location == '-' ? null : location,
      note: note.isEmpty || note == '-' ? null : note,
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
  String _giftKeyFor(GiftModel gift) =>
      '${_dateFormat.format(gift.date)}|${gift.personName.toLowerCase()}|${gift.amount}';

  /// Key used for duplicate detection: same title + date.
  String _weddingKeyFor(WeddingModel wedding) =>
      '${wedding.title.toLowerCase()}|${_dateFormat.format(wedding.date)}';
}
