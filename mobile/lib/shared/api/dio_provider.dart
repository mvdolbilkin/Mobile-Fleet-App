import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.104:8081',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
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
  ));

  return dio;
});
