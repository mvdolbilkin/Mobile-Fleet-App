import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

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
        data: {
          'clid': clid,
          'api_key': apiKey,
          'park_id': parkId,
        },
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
}
