import 'package:dio/dio.dart';

import '../models/models.dart';

class FactCheckApi {
  FactCheckApi({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://10.0.2.2:8080',
          ),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Content-Type': 'application/json'},
        ));

  final Dio _dio;

  Future<FactCheckResult> check(String text, {String language = 'ko'}) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/v1/factcheck',
      data: {'text': text, 'language': language},
    );
    return FactCheckResult.fromJson(text, resp.data ?? const {});
  }
}
