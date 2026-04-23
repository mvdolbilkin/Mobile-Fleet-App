import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/shared/providers/logger_provider.dart';

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

  /// Получить список расходов через backend proxy
  Future<Map<String, dynamic>> getCostsList({
    required String parkId,
    required DateTime dateFrom,
    required DateTime dateTo,
    Map<String, dynamic>? filters,
  }) async {
    try {
      logger.i('Fetching costs list for park: $parkId');
      
      final response = await dio.post(
        '/api/expenses/costs/list',
        data: {
          'filters': filters ?? {},
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
}
