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
  if (Platform.isAndroid)
    return 'http://192.168.1.21:8081/'; // Универсальный адрес эмулятора Android для доступа к localhost хоста
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

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final secureStorage = ref.read(secureStorageServiceProvider);

        // Проверяем наличие cookies (приоритет для закрытого API)
        final sessionId = await secureStorage.getYandexSessionId();
        final sessionId2 = await secureStorage.getYandexSessionId2();
        final loginToken = await secureStorage.getYandexLoginToken();
        final yandexLogin = await secureStorage.getYandexLogin();
        final yandexUid = await secureStorage.getYandexUid();

        if (sessionId != null && sessionId2 != null) {
          // Используем cookies для закрытого API
          final cookieParts = <String>[];

          cookieParts.add('Session_id=$sessionId');
          cookieParts.add('sessionid2=$sessionId2');
          if (loginToken != null) cookieParts.add('L=$loginToken');
          if (yandexLogin != null) cookieParts.add('yandex_login=$yandexLogin');
          if (yandexUid != null) cookieParts.add('yandexuid=$yandexUid');

          options.headers['cookie'] = cookieParts.join('; ');

          // Добавляем park_id если есть
          final parkId = await secureStorage.getParkId();
          if (parkId != null && parkId.isNotEmpty) {
            options.headers['x-park-id'] = parkId;
          }
        } else {
          // Используем API ключи для открытого API
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
        }

        return handler.next(options);
      },
    ),
  );

  return dio;
});
