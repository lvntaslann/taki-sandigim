import 'package:dio/dio.dart';

import 'dio_client.dart';

class GoldRateService {
  GoldRateService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const double _fallbackGoldRateTl = 3200.0;

  Future<double> getGoldRateTl() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://example.com/api/gold-rate',
      );
      final value = response.data?['goldRateTl'];
      if (value is num) return value.toDouble();
      return _fallbackGoldRateTl;
    } catch (_) {
      return _fallbackGoldRateTl;
    }
  }
}
