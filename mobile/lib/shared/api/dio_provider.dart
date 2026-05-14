import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/router.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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

        // Добавляем Authorization Bearer token, если он есть
        final appToken = await secureStorage.getAppToken();
        if (appToken != null && appToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $appToken';
        }

        // Проверяем наличие cookies (приоритет для закрытого API)
        final sessionId = await secureStorage.getYandexSessionId();
        final sessionId2 = await secureStorage.getYandexSessionId2();

        if (sessionId != null && sessionId2 != null) {
          // Пытаемся получить все cookies
          final allCookies = await secureStorage.getAllYandexCookies();
          
          print('🍪 All cookies length: ${allCookies?.length ?? 0}');
          print('🍪 Session_id length: ${sessionId.length}');
          
          if (allCookies != null && allCookies.isNotEmpty) {
            // Используем все сохраненные cookies
            print('✅ Using all saved cookies');
            options.headers['cookie'] = allCookies;
          } else {
            print('⚠️ Using fallback cookies');
            // Fallback: используем только основные cookies
            final loginToken = await secureStorage.getYandexLoginToken();
            final yandexLogin = await secureStorage.getYandexLogin();
            final yandexUid = await secureStorage.getYandexUid();
            
            final cookieParts = <String>[];
            cookieParts.add('Session_id=$sessionId');
            cookieParts.add('sessionid2=$sessionId2');
            if (loginToken != null) cookieParts.add('L=$loginToken');
            if (yandexLogin != null) cookieParts.add('yandex_login=$yandexLogin');
            if (yandexUid != null) cookieParts.add('yandexuid=$yandexUid');
            
            options.headers['cookie'] = cookieParts.join('; ');
          }

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
      onError: (DioException e, handler) async {
        // Перехватываем 401 ошибку (отказ в доступе - токен протух / удален)
        if (e.response?.statusCode == 401) {
          // Игнорируем логин роуты, чтобы нас не зациклило
          if (e.requestOptions.path.contains('/api/auth/login') == false &&
              e.requestOptions.path.contains('/api/auth/webview-session') == false) {
            
            print('⚠️ Token expired or invalid (401). Logging out...');
            
            // Выходим из аккаунта и очищаем все данные вместо вызова AuthService, чтобы избежать циклической зависимости (Circular dependency)
            final secureStorage = ref.read(secureStorageServiceProvider);
            await secureStorage.deleteYandexCredentials();
            await secureStorage.deleteYandexCookies();

            try {
              final cookieManager = CookieManager.instance();
              await cookieManager.deleteAllCookies();
              try {
                await WebStorageManager.instance().android.deleteAllData();
              } catch (_) {}
            } catch (e) {
              print('⚠️ Failed to clear WebView data: $e');
            }

            // Перекидываем пользователя на экран логина
            try {
              final router = ref.read(routerProvider);
              router.go('/login');
            } catch (routeError) {
              print('Router navigation error: $routeError');
            }
          }
        }
        
        // Передаем ошибку дальше по цепочке, не разлогиниваем если это таймаут или нет сети
        return handler.next(e);
      },
    ),
  );

  return dio;
});
