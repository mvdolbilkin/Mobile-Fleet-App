import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String getBaseUrl() {
  if (kIsWeb) return 'http://localhost:8080/';
  if (Platform.isAndroid) return 'http://192.168.1.21:8080/'; // Универсальный адрес эмулятора Android для доступа к localhost хоста
  return 'http://localhost:8080/';
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: getBaseUrl(),
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

  return dio;
});
