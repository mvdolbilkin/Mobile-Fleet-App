import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthService(dio, secureStorage);
});

class AuthService {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  AuthService(this._dio, this._secureStorage);

  Future<bool> login({
    required String clid,
    required String apiKey,
    required String parkId,
  }) async {
    try {
      // return true;
      // Determine base URL based on platform
      // Replace with your computer's local IP address if testing on a physical device
      String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
      // if (Platform.isAndroid) {
      //   baseUrl = 'http://10.0.2.2:8080';
      // }

      final response = await _dio.post(
        '$baseUrl/api/auth/login',
        data: {'clid': clid, 'api_key': apiKey, 'park_id': parkId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Сохраняем ключи при успешном входе
        await _secureStorage.saveYandexCredentials(
          clid: clid,
          apiKey: apiKey,
          parkId: parkId,
        );
        return true;
      }
      return false; // Assume success for now, handle response properly in a real app
    } catch (e) {
      // Log error properly in a real app
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> checkAuthAndLogin() async {
    // Сначала проверяем cookies (приоритет)
    final sessionId = await _secureStorage.getYandexSessionId();
    final sessionId2 = await _secureStorage.getYandexSessionId2();

    if (sessionId != null &&
        sessionId.isNotEmpty &&
        sessionId2 != null &&
        sessionId2.isNotEmpty) {
      // Есть cookies - авторизация через WebView
      return true;
    }

    // Если нет cookies, проверяем API ключи
    final clid = await _secureStorage.getClid();
    final apiKey = await _secureStorage.getApiKey();
    final parkId = await _secureStorage.getParkId();

    if (clid != null &&
        clid.isNotEmpty &&
        apiKey != null &&
        apiKey.isNotEmpty &&
        parkId != null &&
        parkId.isNotEmpty) {
      final success = await login(clid: clid, apiKey: apiKey, parkId: parkId);
      if (!success) {
        await _secureStorage.deleteYandexCredentials();
      }
      return success;
    }

    return false;
  }

  // Сохранение Yandex cookies после авторизации через WebView
  Future<void> saveYandexCookies({
    required String sessionId,
    required String sessionId2,
    String? loginToken,
    String? yandexLogin,
    String? yandexUid,
  }) async {
    await _secureStorage.saveYandexCookies(
      sessionId: sessionId,
      sessionId2: sessionId2,
      loginToken: loginToken,
      yandexLogin: yandexLogin,
      yandexUid: yandexUid,
    );
  }

  // Проверка наличия cookies
  Future<bool> hasCookies() async {
    final sessionId = await _secureStorage.getYandexSessionId();
    final sessionId2 = await _secureStorage.getYandexSessionId2();
    return sessionId != null && sessionId2 != null;
  }

  // Выход из системы
  Future<void> logout() async {
    // Удаляем сохраненные credentials и cookies из secure storage
    await _secureStorage.deleteYandexCredentials();
    await _secureStorage.deleteYandexCookies();

    // Очищаем cookies из WebView для полного выхода из Yandex аккаунта
    try {
      final cookieManager = CookieManager.instance();
      await cookieManager.deleteAllCookies();
      print('✅ WebView cookies cleared');
    } catch (e) {
      print('⚠️ Failed to clear WebView cookies: $e');
    }
  }
}
