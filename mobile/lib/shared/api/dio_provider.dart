import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

String getBaseUrl() {
  final envUrl = dotenv.env['API_BASE_URL'];
  if (envUrl != null && envUrl.isNotEmpty) {
    return envUrl.endsWith('/') ? envUrl : '$envUrl/';
  }

  if (kIsWeb) return 'http://localhost:8080/';
  if (Platform.isAndroid) return 'http://192.168.1.21:8081/'; // Универсальный адрес эмулятора Android для доступа к localhost хоста
  return 'http://localhost:8080/';
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: getBaseUrl(),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(
        seconds: 120,
      ), // Увеличено из-за большого объема данных (limit=4000)
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      request: false,
      requestHeader: false,
      responseBody: false,
      responseHeader: false,
    ),
  );

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final secureStorage = ref.read(secureStorageServiceProvider);
      
      final clid = await secureStorage.getClid();
      final apiKey = await secureStorage.getApiKey();
      final parkId = await secureStorage.getParkId();

      if (clid != null && clid.isNotEmpty) {
        options.headers['X-Client-ID'] = clid;
      }
      if (apiKey != null && apiKey.isNotEmpty) {
        options.headers['X-API-Key'] = apiKey;
      }
      if (parkId != null && parkId.isNotEmpty) {
        options.headers['X-Park-ID'] = parkId;
      }

        return handler.next(options);
      },
    ),
  );

  return dio;
});
