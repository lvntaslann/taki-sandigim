import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../dashboard/data/models/gift_model.dart';
import '../../dashboard/data/models/gift_enums.dart';

class GiftExportService {
  final _dateFormat = DateFormat('d MMM y', 'tr_TR');

  Future<void> shareSummary(List<GiftModel> gifts) async {
    final buffer = StringBuffer('Takı Sandığım - Takı Listem\n\n');
    for (final gift in gifts) {
      buffer.writeln(
        '${_dateFormat.format(gift.date)} - ${gift.personName}: '
        '${gift.giftType.label} (${gift.amount.toStringAsFixed(gift.amount % 1 == 0 ? 0 : 2)}) '
        '- ${gift.estimatedValueTl.toStringAsFixed(0)} TL '
        '[${gift.direction.label}]',
      );
    }
    await Share.share(buffer.toString());
  }

  Future<void> exportAndShare(List<GiftModel> gifts, {required bool asPdf}) async {
    final bytes = asPdf ? await _buildPdfBytes(gifts) : await _buildExcelBytes(gifts);
    final extension = asPdf ? 'pdf' : 'xlsx';
    final file = XFile.fromData(
      bytes,
      name: 'taki_listem.$extension',
      mimeType: asPdf
          ? 'application/pdf'
          : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    await Share.shareXFiles([file]);
  }

  Future<Uint8List> _buildPdfBytes(List<GiftModel> gifts) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'Takı Sandığım - Takı Listem'),
          pw.TableHelper.fromTextArray(
            headers: ['Tarih', 'Kişi', 'Hediye', 'Miktar', 'Değer (TL)', 'Yön'],
            data: gifts
                .map(
                  (gift) => [
                    _dateFormat.format(gift.date),
                    gift.personName,
                    gift.giftType.label,
                    gift.amount.toStringAsFixed(gift.amount % 1 == 0 ? 0 : 2),
                    gift.estimatedValueTl.toStringAsFixed(0),
                    gift.direction.label,
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );
    return document.save();
  }

  Future<Uint8List> _buildExcelBytes(List<GiftModel> gifts) async {
    final workbook = xls.Excel.createExcel();
    final sheet = workbook['Takı Listem'];
    sheet.appendRow([
      xls.TextCellValue('Tarih'),
      xls.TextCellValue('Kişi'),
      xls.TextCellValue('Hediye'),
      xls.TextCellValue('Miktar'),
      xls.TextCellValue('Değer (TL)'),
      xls.TextCellValue('Yön'),
    ]);
    for (final gift in gifts) {
      sheet.appendRow([
        xls.TextCellValue(_dateFormat.format(gift.date)),
        xls.TextCellValue(gift.personName),
        xls.TextCellValue(gift.giftType.label),
        xls.DoubleCellValue(gift.amount),
        xls.DoubleCellValue(gift.estimatedValueTl),
        xls.TextCellValue(gift.direction.label),
      ]);
    }
    return Uint8List.fromList(workbook.encode()!);
  }
}
