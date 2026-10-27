import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../dashboard/data/models/gift_model.dart';
import '../../dashboard/data/models/gift_enums.dart';
import '../../dashboard/data/repositories/wedding_repository.dart';
import '../../../l10n/app_localizations.dart';

/// Writes exports in the app's current language. [GiftImportService] reads
/// back files written in any supported language.
class GiftExportService {
  GiftExportService({WeddingRepository? weddingRepository})
    : _weddingRepository = weddingRepository ?? WeddingRepository();

  final WeddingRepository _weddingRepository;

  /// "27 Eki 2026" / "Oct 27, 2026"; must stay in sync with the import parser.
  static DateFormat dateFormatFor(AppLocalizations l10n) =>
      DateFormat.yMMMd(l10n.localeName);

  /// Currency/unit for the raw `amount` figure — cash gifts are recorded in
  /// either TL or a foreign currency (`currencyCode`); gold/other gift types
  /// don't have a currency, `amount` there is just a piece count.
  String _unitLabel(GiftModel gift) {
    if (gift.giftType != GiftType.cash) return '-';
    return gift.currencyCode ?? 'TL';
  }

  static List<String> giftHeaders(AppLocalizations l10n) => [
    l10n.exportColDate,
    l10n.exportColPerson,
    l10n.exportColGift,
    l10n.exportColAmount,
    l10n.exportColUnit,
    l10n.exportColValueTl,
    l10n.exportColDirection,
  ];

  static List<String> weddingHeaders(AppLocalizations l10n) => [
    l10n.exportColTitle,
    l10n.exportColDate,
    l10n.exportColLocation,
    l10n.exportColNote,
  ];

  Future<void> shareSummary(List<GiftModel> gifts, AppLocalizations l10n) async {
    final dateFormat = dateFormatFor(l10n);
    final weddings = _weddingRepository.getAll();
    final buffer = StringBuffer('${l10n.exportDocumentTitle}\n\n');
    for (final gift in gifts) {
      final formattedAmount = gift.amount.toStringAsFixed(
        gift.amount % 1 == 0 ? 0 : 2,
      );
      final unit = _unitLabel(gift);
      final amountText = unit == '-' ? formattedAmount : '$formattedAmount $unit';
      buffer.writeln(
        '${dateFormat.format(gift.date)} - ${gift.personName}: '
        '${gift.giftType.localizedLabel(l10n)} ($amountText) '
        '- ${gift.estimatedValueTl.toStringAsFixed(0)} TL '
        '[${gift.direction.localizedLabel(l10n)}]',
      );
    }
    if (weddings.isNotEmpty) {
      buffer.writeln('\n${l10n.exportSheetWeddings}\n');
      for (final wedding in weddings) {
        buffer.writeln(
          '${wedding.title} - ${dateFormat.format(wedding.date)}'
          '${wedding.location != null ? ' - ${wedding.location}' : ''}',
        );
      }
    }
    await Share.share(buffer.toString());
  }

  Future<void> exportAndShare(
    List<GiftModel> gifts, {
    required bool asPdf,
    required String fileName,
    required AppLocalizations l10n,
  }) async {
    final bytes = asPdf
        ? await _buildPdfBytes(gifts, l10n)
        : await _buildExcelBytes(gifts, l10n);
    final extension = asPdf ? 'pdf' : 'xlsx';
    final mimeType = asPdf
        ? 'application/pdf'
        : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$fileName.$extension';
    final diskFile = await File(filePath).writeAsBytes(bytes);
    final file = XFile(diskFile.path, name: '$fileName.$extension', mimeType: mimeType);

    await Share.shareXFiles([file]);
  }

  Future<Uint8List> _buildPdfBytes(List<GiftModel> gifts, AppLocalizations l10n) async {
    final dateFormat = dateFormatFor(l10n);
    final weddings = _weddingRepository.getAll();
    final baseFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
    );
    document.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: l10n.exportDocumentTitle),
          pw.TableHelper.fromTextArray(
            headers: giftHeaders(l10n),
            headerStyle: pw.TextStyle(font: boldFont),
            cellStyle: pw.TextStyle(font: baseFont),
            data: gifts
                .map(
                  (gift) => [
                    dateFormat.format(gift.date),
                    gift.personName,
                    gift.giftType.localizedLabel(l10n),
                    gift.amount.toStringAsFixed(gift.amount % 1 == 0 ? 0 : 2),
                    _unitLabel(gift),
                    gift.estimatedValueTl.toStringAsFixed(0),
                    gift.direction.localizedLabel(l10n),
                  ],
                )
                .toList(),
          ),
          if (weddings.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Header(level: 1, text: l10n.exportSheetWeddings),
            pw.TableHelper.fromTextArray(
              headers: weddingHeaders(l10n),
              headerStyle: pw.TextStyle(font: boldFont),
              cellStyle: pw.TextStyle(font: baseFont),
              data: weddings
                  .map(
                    (wedding) => [
                      wedding.title,
                      dateFormat.format(wedding.date),
                      wedding.location ?? '-',
                      wedding.note ?? '-',
                    ],
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
    return document.save();
  }

  Future<Uint8List> _buildExcelBytes(List<GiftModel> gifts, AppLocalizations l10n) async {
    final dateFormat = dateFormatFor(l10n);
    final weddings = _weddingRepository.getAll();
    final workbook = xls.Excel.createExcel();
    final defaultSheetName = workbook.getDefaultSheet()!;
    workbook.rename(defaultSheetName, l10n.exportSheetGifts);
    final giftSheet = workbook[l10n.exportSheetGifts];
    giftSheet.appendRow(giftHeaders(l10n).map(xls.TextCellValue.new).toList());
    for (final gift in gifts) {
      giftSheet.appendRow([
        xls.TextCellValue(dateFormat.format(gift.date)),
        xls.TextCellValue(gift.personName),
        xls.TextCellValue(gift.giftType.localizedLabel(l10n)),
        xls.DoubleCellValue(gift.amount),
        xls.TextCellValue(_unitLabel(gift)),
        xls.DoubleCellValue(gift.estimatedValueTl),
        xls.TextCellValue(gift.direction.localizedLabel(l10n)),
      ]);
    }

    if (weddings.isNotEmpty) {
      final weddingSheet = workbook[l10n.exportSheetWeddings];
      weddingSheet.appendRow(weddingHeaders(l10n).map(xls.TextCellValue.new).toList());
      for (final wedding in weddings) {
        weddingSheet.appendRow([
          xls.TextCellValue(wedding.title),
          xls.TextCellValue(dateFormat.format(wedding.date)),
          xls.TextCellValue(wedding.location ?? '-'),
          xls.TextCellValue(wedding.note ?? '-'),
        ]);
      }
    }

    return Uint8List.fromList(workbook.encode()!);
  }
}
