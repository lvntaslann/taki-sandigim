import 'package:dio/dio.dart';

import 'dio_client.dart';

class SupportedCurrency {
  const SupportedCurrency({
    required this.code,
    required this.label,
    required this.fallbackRateTl,
  });

  final String code;
  final String label;
  final double fallbackRateTl;

  static const List<SupportedCurrency> all = [
    SupportedCurrency(code: 'USD', label: 'Dolar', fallbackRateTl: 40),
    SupportedCurrency(code: 'EUR', label: 'Euro', fallbackRateTl: 43),
    SupportedCurrency(code: 'GBP', label: 'Sterlin', fallbackRateTl: 50),
  ];
}

class CurrencyRateService {
  CurrencyRateService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _endpoint = 'https://finans.truncgil.com/today.json';

  Future<double> getRateTl(String currencyCode) async {
    final fallback = SupportedCurrency.all
        .firstWhere(
          (c) => c.code == currencyCode,
          orElse: () => const SupportedCurrency(
            code: '',
            label: '',
            fallbackRateTl: 1,
          ),
        )
        .fallbackRateTl;

    try {
      final response = await _dio.get<Map<String, dynamic>>(_endpoint);
      final entry = response.data?[currencyCode];
      if (entry is Map) {
        final raw = entry['Satış'] ?? entry['Alış'];
        final parsed = _parseTurkishNumber(raw);
        if (parsed != null) return parsed;
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  double? _parseTurkishNumber(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(normalized);
    }
    return null;
  }
}
