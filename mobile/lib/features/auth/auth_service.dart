import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<bool> login({
    required String clid,
    required String apiKey,
    required String parkId,
  }) async {
    try {
      // Determine base URL based on platform
      // Replace with your computer's local IP address if testing on a physical device
      String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
      if (Platform.isAndroid) {
        baseUrl = 'http://10.0.2.2:8080';
      }
      return true;
      final response = await _dio.post(
        '$baseUrl/api/auth/login',
        data: {
          'clid': clid,
          'api_key': apiKey,
          'park_id': parkId,
        },
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      // Log error properly in a real app
      print('Login error: $e');
      return false;
    }
  }
}
