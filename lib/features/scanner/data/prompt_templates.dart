import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AI prompt wording lives in .env (NOTEBOOK_PROMPT / INVITATION_PROMPT) so
/// it can be tuned without a code change. Newlines are stored as literal
/// `\n` (env values are single-line) and unescaped here; {OCR_TEXT} is
/// swapped for the actual OCR output.
class PromptTemplates {
  PromptTemplates._();

  static String notebook({required String ocrText}) =>
      _fromEnv('NOTEBOOK_PROMPT', ocrText: ocrText);

  static String invitation({required String ocrText}) =>
      _fromEnv('INVITATION_PROMPT', ocrText: ocrText);

  static String _fromEnv(String key, {required String ocrText}) {
    final raw = dotenv.env[key];
    if (raw == null || raw.isEmpty) {
      throw Exception('$key .env dosyasında tanımlı değil.');
    }
    return raw.replaceAll(r'\n', '\n').replaceAll('{OCR_TEXT}', ocrText);
  }
}
