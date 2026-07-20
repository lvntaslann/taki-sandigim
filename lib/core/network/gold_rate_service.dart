import 'package:dio/dio.dart';

import 'dio_client.dart';

class GoldRateService {
  GoldRateService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const double _fallbackGoldRateTl = 3200.0;

  /// Free, key-less endpoint providing live Turkish market rates,
  /// including gram gold buy/sell prices under "gram-altin".
  static const String _endpoint = 'https://finans.truncgil.com/today.json';

  Future<double> getGoldRateTl() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(_endpoint);
      final gramAltin = response.data?['gram-altin'];
      if (gramAltin is Map) {
        final raw = gramAltin['Satış'] ?? gramAltin['Alış'];
        final parsed = _parseTurkishNumber(raw);
        if (parsed != null) return parsed;
      }
      return _fallbackGoldRateTl;
    } catch (_) {
      return _fallbackGoldRateTl;
    }
  }

  /// Parses Turkish-formatted numbers such as "6.092,19" (dot as thousands
  /// separator, comma as decimal separator) into a [double].
  double? _parseTurkishNumber(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(normalized);
    }
    return null;
  }
}
