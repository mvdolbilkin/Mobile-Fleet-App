import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/shared/providers/logger_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepository(
    dio: ref.watch(dioProvider),
    logger: ref.watch(loggerProvider),
  );
});

class ExpensesRepository {
  final Dio dio;
  final dynamic logger;

  ExpensesRepository({
    required this.dio,
    required this.logger,
  });

  /// Получить доступные типы расходов
  Future<List<Map<String, dynamic>>> getAvailableCostTypes({required String parkId}) async {
    final response = await dio.get(
      '/api/expenses/cost-types',
      options: Options(headers: {'X-Park-ID': parkId}),
    );
    final List<dynamic> list = (response.data as Map<String, dynamic>)['cost_types'] as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  /// Получить детали расхода по ID
  Future<Map<String, dynamic>> getCostDetail({
    required String parkId,
    required String costId,
  }) async {
    final response = await dio.get(
      '/api/expenses/costs/$costId',
      options: Options(headers: {'X-Park-ID': parkId}),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Получить список автомобилей для выбора
  Future<List<Map<String, dynamic>>> getSuggestCars({required String parkId}) async {
    final response = await dio.get(
      '/api/expenses/cars/suggest',
      options: Options(headers: {'X-Park-ID': parkId}),
    );
    final List<dynamic> list = (response.data as Map<String, dynamic>)['items'] as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  /// Получить список расходов через backend proxy
  Future<Map<String, dynamic>> getCostsList({
    required String parkId,
    required DateTime dateFrom,
    required DateTime dateTo,
    Map<String, dynamic>? filters,
    String? nameSearchText,
  }) async {
    try {
      logger.i('Fetching costs list for park: $parkId');

      final mergedFilters = <String, dynamic>{
        ...?filters,
        if (nameSearchText != null && nameSearchText.isNotEmpty)
          'name_search_text': nameSearchText,
      };

      final response = await dio.post(
        '/api/expenses/costs/list',
        data: {
          'filters': mergedFilters,
          'date_period': {
            'date_from': dateFrom.toIso8601String().split('T')[0],
            'date_to': dateTo.toIso8601String().split('T')[0],
          },
        },
        options: Options(
          headers: {
            'X-Park-ID': parkId,
          },
        ),
      );

      logger.i('Costs list response: ${response.statusCode}');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      logger.e('Failed to fetch costs list: ${e.message}');
      if (e.response != null) {
        logger.e('Response data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      logger.e('Unexpected error fetching costs list: $e');
      rethrow;
    }
  }

  /// Создать расход
  Future<void> createCost({
    required String parkId,
    required String amount,
    required String carId,
    required String typeId,
    required String name,
    String? comment,
  }) async {
    final data = <String, dynamic>{
      'id': const Uuid().v4(),
      'amount': amount,
      'car_id': carId,
      'type_id': typeId,
      'name': name,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    await dio.post(
      '/api/expenses/costs',
      data: data,
      options: Options(headers: {'X-Park-ID': parkId}),
    );
  }

  /// Обновить расход
  Future<void> updateCost({
    required String parkId,
    required String id,
    required String amount,
    required String carId,
    required String typeId,
    required String name,
    String? comment,
  }) async {
    final data = <String, dynamic>{
      'id': id,
      'amount': amount,
      'car_id': carId,
      'type_id': typeId,
      'name': name,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    await dio.put(
      '/api/expenses/costs',
      data: data,
      options: Options(headers: {'X-Park-ID': parkId}),
    );
  }

  /// Initiate report generation
  Future<void> initiateReportGeneration({
    required String parkId,
    required String operationId,
    required String reportType,
    required Map<String, dynamic> filters,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    logger.i('🚀 Initiating report generation: $reportType, operation: $operationId');
    
    await dio.post(
      '/api/expenses/reports/initiate',
      data: {
        'operation_id': operationId,
        'report_type': reportType,
        'filters': filters,
        'date_period': {
          'date_from': dateFrom.toIso8601String().split('T')[0],
          'date_to': dateTo.toIso8601String().split('T')[0],
        },
      },
      options: Options(headers: {'X-Park-ID': parkId}),
    );
  }

  /// Check report status
  Future<Map<String, dynamic>> checkReportStatus({
    required String parkId,
    required String operationId,
  }) async {
    final response = await dio.get(
      '/api/expenses/reports/status',
      queryParameters: {'operation_id': operationId},
      options: Options(headers: {'X-Park-ID': parkId}),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get report download link
  Future<Map<String, dynamic>> getReportDownloadLink({
    required String parkId,
    required String operationId,
  }) async {
    final response = await dio.get(
      '/api/expenses/reports/download',
      queryParameters: {'operation_id': operationId},
      options: Options(headers: {'X-Park-ID': parkId}),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Download report file to device
  Future<String> downloadReportFile({
    required String url,
    required String fileName,
  }) async {
    logger.i('📥 Downloading file: $fileName from $url');

    // First, download file to memory
    final response = await dio.get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to download file: ${response.statusCode}');
    }

    final bytes = Uint8List.fromList(response.data as List<int>);
    logger.i('📦 Downloaded ${bytes.length} bytes');

    // Add timestamp to filename to make it unique
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final nameParts = fileName.split('.');
    final extension = nameParts.length > 1 ? nameParts.last : 'csv';
    final baseName = nameParts.length > 1
        ? nameParts.sublist(0, nameParts.length - 1).join('.')
        : fileName;
    final uniqueFileName = '${baseName}_$timestamp.$extension';

    // Let user choose where to save with bytes
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Сохранить отчет',
      fileName: uniqueFileName,
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: bytes,
    );

    if (outputPath == null) {
      throw Exception('Сохранение отменено пользователем');
    }

    logger.i('✅ File saved to: $outputPath');
    return outputPath;
  }
}
