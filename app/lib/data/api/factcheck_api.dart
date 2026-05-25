import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';

String _defaultBaseUrl() {
  const fromEnv = String.fromEnvironment('API_BASE_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  // Web / iOS sim / desktop can reach the host's loopback directly.
  // Android emulator needs the special alias 10.0.2.2.
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080';
  }
  return 'http://localhost:8080';
}

class FactCheckApi {
  FactCheckApi({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? _defaultBaseUrl(),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 180),
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
