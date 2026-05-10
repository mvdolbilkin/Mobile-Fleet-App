import 'package:dio/dio.dart';
import 'package:mobile/features/fleet/domain/car_category_model.dart';

class CarCategoryService {
  final Dio _dio;

  CarCategoryService(this._dio);

  Future<List<CarCategory>> getCarCategories() async {
    final response = await _dio.get('api/fleet/references/car-categories');
    final data = response.data as Map<String, dynamic>;
    final list = data['car_categories'] as List? ?? [];
    return list
        .map((e) => CarCategory.fromJson(e as Map<String, dynamic>))
        .where((c) => c.name.isNotEmpty)
        .toList();
  }
}
