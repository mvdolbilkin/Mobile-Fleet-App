import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

// Filter model
class RentsFilter {
  final List<String> categories;
  final List<String> statuses;
  final bool isRental;
  final int pageSize;

  const RentsFilter({
    this.categories = const [],
    this.statuses = const [],
    this.isRental = true,
    this.pageSize = 25,
  });

  static RentsFilter get defaultFilter => const RentsFilter(
        categories: [],
        statuses: [],
        isRental: true,
        pageSize: 25,
      );

  bool get isModified {
    final def = defaultFilter;
    return categories.isNotEmpty ||
        statuses.isNotEmpty ||
        isRental != def.isRental ||
        pageSize != def.pageSize;
  }

  RentsFilter copyWith({
    List<String>? categories,
    List<String>? statuses,
    bool? isRental,
    int? pageSize,
  }) {
    return RentsFilter(
      categories: categories ?? this.categories,
      statuses: statuses ?? this.statuses,
      isRental: isRental ?? this.isRental,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

// Reference models
class CarCategory {
  final String id;
  final String name;

  const CarCategory({required this.id, required this.name});

  factory CarCategory.fromJson(Map<String, dynamic> json) {
    return CarCategory(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class CarStatus {
  final String id;
  final String name;

  const CarStatus({required this.id, required this.name});

  factory CarStatus.fromJson(Map<String, dynamic> json) {
    return CarStatus(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class RegularChargeTariff {
  final String id;
  final String name;

  const RegularChargeTariff({required this.id, required this.name});

  factory RegularChargeTariff.fromJson(Map<String, dynamic> json) {
    return RegularChargeTariff(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

// Providers for fetching reference data
final carCategoriesProvider = FutureProvider.autoDispose<List<CarCategory>>((ref) async {
  final dio = ref.watch(dioProvider);
  final parkId = await ref.watch(secureStorageServiceProvider).getParkId();
  
  if (parkId == null) {
    throw Exception('Park ID not found');
  }

  final response = await dio.post(
    '/api/vehicles/references',
    data: {
      'references': ['car_categories']
    },
    options: Options(
      headers: {'X-Park-ID': parkId},
    ),
  );

  final data = response.data as Map<String, dynamic>;
  final categoriesJson = data['car_categories'] as List<dynamic>? ?? [];
  
  return categoriesJson
      .map((e) => CarCategory.fromJson(e as Map<String, dynamic>))
      .where((c) => c.id != 'none')
      .toList();
});

final carStatusesProvider = FutureProvider.autoDispose<List<CarStatus>>((ref) async {
  final dio = ref.watch(dioProvider);
  final parkId = await ref.watch(secureStorageServiceProvider).getParkId();
  
  if (parkId == null) {
    throw Exception('Park ID not found');
  }

  final response = await dio.post(
    '/api/vehicles/references',
    data: {
      'references': ['car_statuses']
    },
    options: Options(
      headers: {'X-Park-ID': parkId},
    ),
  );

  final data = response.data as Map<String, dynamic>;
  final statusesJson = data['car_statuses'] as List<dynamic>? ?? [];
  
  return statusesJson
      .map((e) => CarStatus.fromJson(e as Map<String, dynamic>))
      .toList();
});

final regularChargeTariffsProvider = FutureProvider.autoDispose<List<RegularChargeTariff>>((ref) async {
  final dio = ref.watch(dioProvider);
  final parkId = await ref.watch(secureStorageServiceProvider).getParkId();
  
  if (parkId == null) {
    throw Exception('Park ID not found');
  }

  final response = await dio.post(
    '/api/vehicles/references',
    data: {
      'references': ['regular_charge_asset_types']
    },
    options: Options(
      headers: {'X-Park-ID': parkId},
    ),
  );

  final data = response.data as Map<String, dynamic>;
  final tariffsJson = data['regular_charge_asset_types'] as List<dynamic>? ?? [];
  
  return tariffsJson
      .map((e) => RegularChargeTariff.fromJson(e as Map<String, dynamic>))
      .toList();
});
