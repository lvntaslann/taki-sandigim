import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/services/purchase_service.dart';
import '../domain/invitation_info.dart';
import '../domain/notebook_line.dart';

/// Calls the `aiEvaluate` Cloud Function instead of the AI provider
/// directly, so the API key, model, provider and prompts all live on the
/// backend and can change without a new app release.
class AiEvaluationService {
  AiEvaluationService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static String get _functionUrl =>
      dotenv.env['AI_FUNCTION_URL'] ??
      'https://europe-west1-taki-sandigim.cloudfunctions.net/aiEvaluate';

  Future<List<NotebookLine>> evaluateNotebook({
    required String imagePath,
    required String ocrText,
  }) async {
    final data = await _evaluate(
      type: 'notebook',
      imagePath: imagePath,
      ocrText: ocrText,
    );
    final lines = data['lines'] as List?;
    if (lines == null) {
      throw Exception('AI yanıtında beklenen alan bulunamadı: lines');
    }
    return lines
        .whereType<Map<String, dynamic>>()
        .map((entry) {
          final personName = (entry['personName'] as String? ?? '').trim();
          final giftDescription = (entry['giftDescription'] as String? ?? '').trim();
          final amount = (entry['amount'] as num?)?.toDouble();
          return NotebookLine(
            personName: personName,
            giftDescription: giftDescription,
            amount: amount,
            rawText: [personName, giftDescription, amount?.toString()]
                .where((s) => s != null && s.isNotEmpty)
                .join(' · '),
          );
        })
        .where((line) => line.personName.isNotEmpty)
        .toList();
  }

  Future<InvitationInfo> evaluateInvitation({
    required String imagePath,
    required String ocrText,
  }) async {
    final data = await _evaluate(
      type: 'invitation',
      imagePath: imagePath,
      ocrText: ocrText,
    );
    final info = data['invitation'] as Map<String, dynamic>?;
    if (info == null) {
      throw Exception('AI yanıtında beklenen alan bulunamadı: invitation');
    }
    final dateStr = info['date'] as String?;
    return InvitationInfo(
      title: (info['title'] as String? ?? '').trim(),
      date: dateStr != null ? DateTime.tryParse(dateStr) : null,
      time: (info['time'] as String?)?.trim(),
      location: (info['location'] as String?)?.trim(),
    );
  }

  Future<Map<String, dynamic>> _evaluate({
    required String type,
    required String imagePath,
    required String ocrText,
  }) async {
    final appUserId = PurchaseService.instance.appUserId;
    if (appUserId == null || appUserId.isEmpty) {
      throw Exception('Kullanıcı kimliği bulunamadı, lütfen tekrar dene.');
    }

    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _functionUrl,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          'appUserId': appUserId,
          'type': type,
          'ocrText': ocrText,
          'imageBase64': base64Image,
          'mimeType': _mimeTypeFor(imagePath),
        },
      );
      return response.data ?? const {};
    } on DioException catch (e) {
      throw Exception(_describeError(e));
    }
  }

  String _mimeTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.heif')) return 'image/heif';
    return 'image/jpeg';
  }

  String _describeError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }
    if (e.response?.statusCode == 429) {
      return 'Şu an yoğunluktan dolayı AI yanıt veremedi (rate limit). Birkaç saniye sonra tekrar dene.';
    }
    return 'AI değerlendirme isteği başarısız: ${e.message}';
  }
}
