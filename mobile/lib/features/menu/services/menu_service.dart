import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/menu/models/contractors_model.dart';
import 'package:mobile/features/menu/models/cars_model.dart';
import 'package:mobile/features/menu/models/loyalty_program_model.dart';
import 'package:mobile/features/menu/models/problems_model.dart';
import 'package:mobile/shared/api/dio_provider.dart';

class MenuService {
  final Dio _dio;

  MenuService(this._dio);

  Future<ContractorsData> getContractorsWidget({
    required String dateFrom,
    required String dateTo,
  }) async {
    try {
      final response = await _dio.post(
        '/api/menu/contractors',
        data: {'date_from': dateFrom, 'date_to': dateTo},
      );

      return ContractorsData.fromJson(response.data);
    } catch (e) {
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

      return CarsData.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<LoyaltyProgramData> getLoyaltyProgram() async {
    try {
      final response = await _dio.post('/api/menu/loyalty');
      return LoyaltyProgramData.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ProblemsData> getProblems() async {
    try {
      final response = await _dio.post('/api/menu/problems');
      return ProblemsData.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

final menuServiceProvider = Provider<MenuService>((ref) {
  final dio = ref.watch(dioProvider);
  return MenuService(dio);
});
