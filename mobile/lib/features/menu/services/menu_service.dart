import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/menu/models/contractors_model.dart';
import 'package:mobile/features/menu/models/cars_model.dart';
import 'package:mobile/features/menu/models/loyalty_program_model.dart';
import 'package:mobile/features/menu/models/problems_model.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/shared/providers/logger_provider.dart';
import 'package:logger/logger.dart';

class MenuService {
  final Dio _dio;
  final Logger _logger;

  MenuService(this._dio, this._logger);

  Future<ContractorsData> getContractorsWidget({
    required String dateFrom,
    required String dateTo,
  }) async {
    try {
      final response = await _dio.post(
        '/api/menu/contractors',
        data: {'date_from': dateFrom, 'date_to': dateTo},
      );
      _logger.i('getContractorsWidget: ${response.statusCode}');
      return ContractorsData.fromJson(response.data);
    } catch (e) {
      _logger.e('getContractorsWidget error: $e');
      rethrow;
    }
  }

  Future<CarsData> getCarsWidget({
    required String dateFrom,
    required String dateTo,
  }) async {
    try {
      final response = await _dio.post(
        '/api/menu/cars',
        data: {'date_from': dateFrom, 'date_to': dateTo},
      );

      _logger.i('getCarsWidget: ${response.statusCode}');
      return CarsData.fromJson(response.data);
    } catch (e) {
      _logger.e('getCarsWidget error: $e');
      rethrow;
    }
  }

  Future<LoyaltyProgramData> getLoyaltyProgram() async {
    try {
      final response = await _dio.post('/api/menu/loyalty', data: {});
      _logger.i('getLoyaltyProgram: ${response.statusCode}');
      return LoyaltyProgramData.fromJson(response.data);
    } catch (e) {
      _logger.e('getLoyaltyProgram error: $e');
      rethrow;
    }
  }

  Future<ProblemsData> getProblems() async {
    try {
      final response = await _dio.post('/api/menu/problems');
      _logger.i('getProblems: ${response.statusCode}');
      return ProblemsData.fromJson(response.data);
    } catch (e) {
      _logger.e('getProblems error: $e');
      rethrow;
    }
  }
}

final menuServiceProvider = Provider<MenuService>((ref) {
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(loggerProvider);
  return MenuService(dio, logger);
});
