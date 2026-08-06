import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../domain/invitation_info.dart';
import '../domain/notebook_line.dart';
import 'prompt_templates.dart';


class AiEvaluationService {
  AiEvaluationService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static String get _model => dotenv.env['AI_MODEL'] ?? '';
  static String get _baseUrl =>
      dotenv.env['AI_API_BASE_URL'] ??
      '';
  static String get _endpoint => '$_baseUrl/models/$_model:generateContent';

  static const _maxAttempts = 3;
  static const _retryDelays = [Duration(seconds: 2), Duration(seconds: 5)];

  Future<List<NotebookLine>> evaluateNotebook({
    required String imagePath,
    required String ocrText,
  }) async {
    final content = await _requestText(
      imagePath: imagePath,
      prompt: PromptTemplates.notebook(ocrText: ocrText),
    );
    return _parseNotebookLines(content);
  }

  Future<InvitationInfo> evaluateInvitation({
    required String imagePath,
    required String ocrText,
  }) async {
    final content = await _requestText(
      imagePath: imagePath,
      prompt: PromptTemplates.invitation(ocrText: ocrText),
    );
    return _parseInvitation(content);
  }

  Future<String> _requestText({
    required String imagePath,
    required String prompt,
  }) async {
    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = _mimeTypeFor(imagePath);

    Response<Map<String, dynamic>>? response;
    DioException? lastError;

    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      try {
        response = await _dio.post<Map<String, dynamic>>(
          _endpoint,
          options: Options(
            headers: {
              'X-goog-api-key': dotenv.env['AI_API_KEY'] ?? '',
              'Content-Type': 'application/json',
            },
          ),
          data: {
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                  {
                    'inline_data': {
                      'mime_type': mimeType,
                      'data': base64Image,
                    },
                  },
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.2,
              'maxOutputTokens': 4096,
            },
          },
        );
        break;
      } on DioException catch (e) {
        lastError = e;
        if (!_isRateLimited(e) || attempt == _maxAttempts - 1) {
          throw Exception(_describeError(e));
        }
        await Future.delayed(_retryDelays[attempt]);
      }
    }

    if (response == null) {
      throw Exception(_describeError(lastError!));
    }

    final content = response.data?['candidates']?[0]?['content']?['parts']?[0]?['text']
        as String?;
    if (kDebugMode) {
      debugPrint('AiEvaluationService raw response: ${response.data}');
      debugPrint('AiEvaluationService extracted text: $content');
    }
    if (content == null || content.trim().isEmpty) {
      final finishReason = response.data?['candidates']?[0]?['finishReason'];
      throw Exception(
        finishReason != null
            ? 'AI boş bir yanıt döndürdü (finishReason: $finishReason).'
            : 'AI boş bir yanıt döndürdü.',
      );
    }
    return content;
  }

  String _mimeTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.heif')) return 'image/heif';
    return 'image/jpeg';
  }

  bool _isRateLimited(DioException e) {
    if (e.response?.statusCode == 429) return true;
    final status = e.response?.data is Map
        ? (e.response?.data['error']?['status'] as String?)
        : null;
    return status == 'RESOURCE_EXHAUSTED';
  }

  String _describeError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        final message = error['message'] as String?;
        final status = error['status'];
        final parts = [
          if (message != null) message,
          if (status != null) '(status: $status)',
        ];
        if (parts.isNotEmpty) return 'AI değerlendirme hatası: ${parts.join(' — ')}';
      }
    }
    return 'AI değerlendirme isteği başarısız: ${e.message}';
  }

  List<NotebookLine> _parseNotebookLines(String content) {
    final decoded = _extractJson(content, opening: '[', closing: ']');
    if (decoded is! List) {
      throw const FormatException('AI yanıtı beklenen JSON dizisi formatında değil.');
    }

    return decoded
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

  InvitationInfo _parseInvitation(String content) {
    final decoded = _extractJson(content, opening: '{', closing: '}');
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('AI yanıtı beklenen JSON nesnesi formatında değil.');
    }

    final dateStr = decoded['date'] as String?;
    return InvitationInfo(
      title: (decoded['title'] as String? ?? '').trim(),
      date: dateStr != null ? DateTime.tryParse(dateStr) : null,
      time: (decoded['time'] as String?)?.trim(),
      location: (decoded['location'] as String?)?.trim(),
    );
  }

  dynamic _extractJson(String content, {required String opening, required String closing}) {
    final start = content.indexOf(opening);
    final end = content.lastIndexOf(closing);
    if (start == -1 || end == -1 || end < start) {
      throw FormatException('AI yanıtında geçerli bir JSON bulunamadı ("$opening...$closing").');
    }
    return jsonDecode(content.substring(start, end + 1));
  }
}
