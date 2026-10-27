import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../dashboard/data/models/gift_enums.dart';
import '../../dashboard/data/models/gift_model.dart';
import '../../dashboard/data/models/wedding_model.dart';
import '../../dashboard/data/repositories/gift_repository.dart';
import '../../dashboard/data/repositories/wedding_repository.dart';
import '../../../l10n/app_localizations.dart';
import 'gift_export_service.dart';

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

  /// Every language an export may have been written in.
  static final _fileLanguages = [
    for (final locale in AppLocalizations.supportedLocales)
      lookupAppLocalizations(locale),
  ];

  /// Locale-independent, date-only key part for duplicate detection.
  static final _keyDateFormat = DateFormat('y-MM-dd');
  final _uuid = const Uuid();

  /// Opens a file picker for .xlsx files, validates the format, and restores
  /// both the gift list sheet and the wedding/invitation sheet our own export
  /// writes, in whichever supported language the file was exported. Duplicate
  /// rows are skipped (same date + person name + amount for gifts, same
  /// title + date for weddings). Error messages use [l10n], the app language.
  ///
  /// Returns null if the user cancelled the file picker.
  Future<GiftImportResult?> pickAndImport(AppLocalizations l10n) async {
    final pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    final bytes = pickerResult?.files.single.bytes;
    if (bytes == null) return null;

    final workbook = xls.Excel.decodeBytes(bytes);
    if (workbook.tables.isEmpty) {
      throw GiftImportFormatException(l10n.importNoSheet);
    }
    // Prefer the sheet our own export writes to; workbooks may also contain
    // an empty default sheet (e.g. "Sheet1") alongside it.
    final sheet = _fileLanguages
            .map((file) => workbook.tables[file.exportSheetGifts])
            .nonNulls
            .firstOrNull ??
        workbook.tables.values.firstWhere(
          (table) => table.rows.isNotEmpty,
          orElse: () => workbook.tables.values.first,
        );
    final rows = sheet.rows;
    if (rows.isEmpty) {
      throw GiftImportFormatException(l10n.importEmptyFile);
    }

    final headerCells = _headerCells(rows.first);
    // The unit column is optional, as in files exported before it existed.
    final fileLanguage = _fileLanguages
        .where((file) {
          final required = GiftExportService.giftHeaders(file)
            ..remove(file.exportColUnit);
          return required.every(headerCells.contains);
        })
        .firstOrNull;
    if (fileLanguage == null) {
      throw GiftImportFormatException(l10n.importWrongFormat);
    }
    final columnIndex = {
      for (final header in headerCells) header: headerCells.indexOf(header),
    };

    final addedCount = await _importGifts(rows, columnIndex, fileLanguage);
    final addedWeddingCount = await _importWeddings(
      workbook.tables[fileLanguage.exportSheetWeddings],
      fileLanguage,
    );

    return GiftImportResult(addedCount: addedCount, addedWeddingCount: addedWeddingCount);
  }

  List<String> _headerCells(List<xls.Data?> row) =>
      row.map((cell) => cell?.value?.toString().trim() ?? '').toList();

  Future<int> _importGifts(
    List<List<xls.Data?>> rows,
    Map<String, int> columnIndex,
    AppLocalizations file,
  ) async {
    final existingKeys = _repository.getAll().map(_giftKeyFor).toSet();

    var addedCount = 0;
    for (final row in rows.skip(1)) {
      final gift = _parseGiftRow(row, columnIndex, file);
      if (gift == null) continue;
      final key = _giftKeyFor(gift);
      if (existingKeys.contains(key)) continue;

      await _repository.save(gift);
      existingKeys.add(key);
      addedCount++;
    }
    return addedCount;
  }

  Future<int> _importWeddings(xls.Sheet? sheet, AppLocalizations file) async {
    if (sheet == null || sheet.rows.isEmpty) return 0;

    final headerCells = _headerCells(sheet.rows.first);
    if (!GiftExportService.weddingHeaders(file).every(headerCells.contains)) {
      return 0;
    }
    final columnIndex = {
      for (final header in headerCells) header: headerCells.indexOf(header),
    };

    final existingKeys = _weddingRepository.getAll().map(_weddingKeyFor).toSet();

    var addedCount = 0;
    for (final row in sheet.rows.skip(1)) {
      final wedding = _parseWeddingRow(row, columnIndex, file);
      if (wedding == null) continue;
      final key = _weddingKeyFor(wedding);
      if (existingKeys.contains(key)) continue;

      await _weddingRepository.save(wedding);
      existingKeys.add(key);
      addedCount++;
    }
    return addedCount;
  }

  GiftModel? _parseGiftRow(
    List<xls.Data?> row,
    Map<String, int> columnIndex,
    AppLocalizations file,
  ) {
    String textAt(String header) {
      final index = columnIndex[header];
      if (index == null || index >= row.length) return '';
      return row[index]?.value?.toString().trim() ?? '';
    }

    final dateText = textAt(file.exportColDate);
    final personName = textAt(file.exportColPerson);
    final giftLabel = textAt(file.exportColGift);
    final amountText = textAt(file.exportColAmount);
    final unitText = textAt(file.exportColUnit);
    final valueText = textAt(file.exportColValueTl);
    final directionLabel = textAt(file.exportColDirection);

    if (personName.isEmpty) return null;

    final date = _tryParseDate(dateText, file);
    if (date == null) return null;

    final giftType = GiftType.values
        .where((type) => type.localizedLabel(file) == giftLabel)
        .firstOrNull;
    if (giftType == null) return null;

    final direction = GiftDirection.values
        .where((direction) => direction.localizedLabel(file) == directionLabel)
        .firstOrNull;
    if (direction == null) return null;

    final amount = double.tryParse(amountText.replaceAll(',', '.'));
    if (amount == null) return null;

    final estimatedValueTl = double.tryParse(valueText.replaceAll(',', '.'));
    if (estimatedValueTl == null) return null;

    // The unit column is only meaningful for cash gifts: 'TL', a foreign
    // currency code (e.g. 'USD'), or '-' for gold/other types.
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

  WeddingModel? _parseWeddingRow(
    List<xls.Data?> row,
    Map<String, int> columnIndex,
    AppLocalizations file,
  ) {
    String textAt(String header) {
      final index = columnIndex[header];
      if (index == null || index >= row.length) return '';
      return row[index]?.value?.toString().trim() ?? '';
    }

    final title = textAt(file.exportColTitle);
    final dateText = textAt(file.exportColDate);
    final location = textAt(file.exportColLocation);
    final note = textAt(file.exportColNote);

    if (title.isEmpty) return null;

    final date = _tryParseDate(dateText, file);
    if (date == null) return null;

    return WeddingModel(
      id: _uuid.v4(),
      title: title,
      date: date,
      location: location.isEmpty || location == '-' ? null : location,
      note: note.isEmpty || note == '-' ? null : note,
    );
  }

  DateTime? _tryParseDate(String text, AppLocalizations file) {
    if (text.isEmpty) return null;
    try {
      return GiftExportService.dateFormatFor(file).parse(text);
    } catch (_) {
      return null;
    }
  }

  /// Key used for duplicate detection: same date + person + amount.
  String _giftKeyFor(GiftModel gift) =>
      '${_keyDateFormat.format(gift.date)}|${gift.personName.toLowerCase()}|${gift.amount}';

  /// Key used for duplicate detection: same title + date.
  String _weddingKeyFor(WeddingModel wedding) =>
      '${wedding.title.toLowerCase()}|${_keyDateFormat.format(wedding.date)}';
}
