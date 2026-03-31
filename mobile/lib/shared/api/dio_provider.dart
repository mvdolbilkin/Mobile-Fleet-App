import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

String getBaseUrl() {
  if (kIsWeb) return 'http://localhost:8080/';
  if (Platform.isAndroid) return 'http://192.168.1.21:8080/'; // Универсальный адрес эмулятора Android для доступа к localhost хоста
  return 'http://localhost:8080/';
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
<<<<<<< HEAD
      baseUrl: getBaseUrl(),
=======
      baseUrl: 'http://192.168.1.104:8081',
>>>>>>> e5b0a558ada60dbd128c0b5191c75c588de2b361
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 35),
    ),
  );

  dio.interceptors.add(LogInterceptor(
    request: false,
    requestHeader: false,
    responseBody: false,
    responseHeader: false,
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final secureStorage = ref.read(secureStorageServiceProvider);
      
      final clid = await secureStorage.getClid();
      final apiKey = await secureStorage.getApiKey();

      if (clid != null && clid.isNotEmpty) {
        options.headers['X-Client-ID'] = clid;
      }
      if (apiKey != null && apiKey.isNotEmpty) {
        options.headers['X-API-Key'] = apiKey;
      }

      return handler.next(options);
    },
  ));

  return dio;
});
