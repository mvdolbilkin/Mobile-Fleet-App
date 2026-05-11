import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/data/car_category_service.dart';
import 'package:mobile/features/fleet/domain/car_category_model.dart';
import 'package:mobile/shared/api/dio_provider.dart';

final carCategoryServiceProvider = Provider<CarCategoryService>((ref) {
  return CarCategoryService(ref.watch(dioProvider));
});

final efficiencyCarCategoriesProvider = FutureProvider<List<CarCategory>>((ref) {
  return ref.read(carCategoryServiceProvider).getCarCategories();
});
