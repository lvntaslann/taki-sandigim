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

class GiftExportService {
  GiftExportService({WeddingRepository? weddingRepository})
    : _weddingRepository = weddingRepository ?? WeddingRepository();

  final WeddingRepository _weddingRepository;
  final _dateFormat = DateFormat('d MMM y', 'tr_TR');

  /// Currency/unit for the raw `amount` figure — cash gifts are recorded in
  /// either TL or a foreign currency (`currencyCode`); gold/other gift types
  /// don't have a currency, `amount` there is just a piece count.
  String _unitLabel(GiftModel gift) {
    if (gift.giftType != GiftType.cash) return '-';
    return gift.currencyCode ?? 'TL';
  }

  Future<void> shareSummary(List<GiftModel> gifts) async {
    final weddings = _weddingRepository.getAll();
    final buffer = StringBuffer('Takı Sandığım - Takı Listem\n\n');
    for (final gift in gifts) {
      final formattedAmount = gift.amount.toStringAsFixed(
        gift.amount % 1 == 0 ? 0 : 2,
      );
      final unit = _unitLabel(gift);
      final amountText = unit == '-' ? formattedAmount : '$formattedAmount $unit';
      buffer.writeln(
        '${_dateFormat.format(gift.date)} - ${gift.personName}: '
        '${gift.giftType.label} ($amountText) '
        '- ${gift.estimatedValueTl.toStringAsFixed(0)} TL '
        '[${gift.direction.label}]',
      );
    }
    if (weddings.isNotEmpty) {
      buffer.writeln('\nDavetiye Bilgileri\n');
      for (final wedding in weddings) {
        buffer.writeln(
          '${wedding.title} - ${_dateFormat.format(wedding.date)}'
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
  }) async {
    final bytes = asPdf ? await _buildPdfBytes(gifts) : await _buildExcelBytes(gifts);
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

  Future<Uint8List> _buildPdfBytes(List<GiftModel> gifts) async {
    final weddings = _weddingRepository.getAll();
    final baseFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
    );
    document.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'Takı Sandığım - Takı Listem'),
          pw.TableHelper.fromTextArray(
            headers: ['Tarih', 'Kişi', 'Hediye', 'Miktar', 'Birim', 'Değer (TL)', 'Yön'],
            headerStyle: pw.TextStyle(font: boldFont),
            cellStyle: pw.TextStyle(font: baseFont),
            data: gifts
                .map(
                  (gift) => [
                    _dateFormat.format(gift.date),
                    gift.personName,
                    gift.giftType.label,
                    gift.amount.toStringAsFixed(gift.amount % 1 == 0 ? 0 : 2),
                    _unitLabel(gift),
                    gift.estimatedValueTl.toStringAsFixed(0),
                    gift.direction.label,
                  ],
                )
                .toList(),
          ),
          if (weddings.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Header(level: 1, text: 'Davetiye Bilgileri'),
            pw.TableHelper.fromTextArray(
              headers: ['Başlık', 'Tarih', 'Konum', 'Not'],
              headerStyle: pw.TextStyle(font: boldFont),
              cellStyle: pw.TextStyle(font: baseFont),
              data: weddings
                  .map(
                    (wedding) => [
                      wedding.title,
                      _dateFormat.format(wedding.date),
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

  Future<Uint8List> _buildExcelBytes(List<GiftModel> gifts) async {
    final weddings = _weddingRepository.getAll();
    final workbook = xls.Excel.createExcel();
    final defaultSheetName = workbook.getDefaultSheet()!;
    workbook.rename(defaultSheetName, 'Takı Listem');
    final giftSheet = workbook['Takı Listem'];
    giftSheet.appendRow([
      xls.TextCellValue('Tarih'),
      xls.TextCellValue('Kişi'),
      xls.TextCellValue('Hediye'),
      xls.TextCellValue('Miktar'),
      xls.TextCellValue('Birim'),
      xls.TextCellValue('Değer (TL)'),
      xls.TextCellValue('Yön'),
    ]);
    for (final gift in gifts) {
      giftSheet.appendRow([
        xls.TextCellValue(_dateFormat.format(gift.date)),
        xls.TextCellValue(gift.personName),
        xls.TextCellValue(gift.giftType.label),
        xls.DoubleCellValue(gift.amount),
        xls.TextCellValue(_unitLabel(gift)),
        xls.DoubleCellValue(gift.estimatedValueTl),
        xls.TextCellValue(gift.direction.label),
      ]);
    }

    if (weddings.isNotEmpty) {
      final weddingSheet = workbook['Davetiye Bilgileri'];
      weddingSheet.appendRow([
        xls.TextCellValue('Başlık'),
        xls.TextCellValue('Tarih'),
        xls.TextCellValue('Konum'),
        xls.TextCellValue('Not'),
      ]);
      for (final wedding in weddings) {
        weddingSheet.appendRow([
          xls.TextCellValue(wedding.title),
          xls.TextCellValue(_dateFormat.format(wedding.date)),
          xls.TextCellValue(wedding.location ?? '-'),
          xls.TextCellValue(wedding.note ?? '-'),
        ]);
      }
    }

    return Uint8List.fromList(workbook.encode()!);
  }
}
