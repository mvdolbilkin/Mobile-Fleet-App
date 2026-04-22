import 'package:dio/dio.dart';
import 'package:mobile/features/fleet/domain/vehicle.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

class VehicleFilter {
  final String? searchQuery;
  final List<VehicleType>? types;
  final List<VehicleOwner>? owners;
  final List<VehicleUsageRight>? usageRights;
  final List<VehicleStatus>? statuses;
  final List<VehicleCategory>? categories;

  const VehicleFilter({
    this.searchQuery,
    this.types,
    this.owners,
    this.usageRights,
    this.statuses,
    this.categories,
  });

  VehicleFilter copyWith({
    String? searchQuery,
    List<VehicleType>? types,
    List<VehicleOwner>? owners,
    List<VehicleUsageRight>? usageRights,
    List<VehicleStatus>? statuses,
    List<VehicleCategory>? categories,
  }) {
    return VehicleFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      types: types ?? this.types,
      owners: owners ?? this.owners,
      usageRights: usageRights ?? this.usageRights,
      statuses: statuses ?? this.statuses,
      categories: categories ?? this.categories,
    );
  }

  bool get isEmpty =>
      (searchQuery == null || searchQuery!.isEmpty) &&
      (types == null || types!.isEmpty) &&
      (owners == null || owners!.isEmpty) &&
      (usageRights == null || usageRights!.isEmpty) &&
      (statuses == null || statuses!.isEmpty) &&
      (categories == null || categories!.isEmpty);
}

class VehiclesService {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  VehiclesService(this._dio, this._secureStorage);

  Future<List<Vehicle>> getVehicles(VehicleFilter filter) async {
    try {
      final parkId = await _secureStorage.getParkId();
      if (parkId == null || parkId.isEmpty) {
        throw Exception('Park ID is not available. Please login again.');
      }

      // Формируем payload для Yandex API (через наш бэкенд-прокси)
      final Map<String, dynamic> payload = {
        "limit": 1000,
        "offset": 0,
        "query": {
          "park": {"id": parkId, "car": _buildCarFilters(filter)},
        },
        "fields": {
          "car": [
            "id",
            "status",
            "amenities",
            "category",
            "callsign",
            "brand",
            "model",
            "year",
            "color",
            "number",
            "registration_cert",
            "vin",
          ],
        },
      };

      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        payload['query']['text'] = filter.searchQuery;
      }

      final response = await _dio.post('/api/vehicles/list', data: payload);

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['cars'] != null) {
        final List<dynamic> carsJson = response.data['cars'];

        var result = carsJson
            .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
            .toList();

        // Локальная фильтрация для полей, которых нет в API Яндекса
        if (filter.types != null && filter.types!.isNotEmpty) {
          result = result.where((v) => filter.types!.contains(v.type)).toList();
        }
        if (filter.owners != null && filter.owners!.isNotEmpty) {
          result = result
              .where((v) => filter.owners!.contains(v.owner))
              .toList();
        }
        if (filter.usageRights != null && filter.usageRights!.isNotEmpty) {
          result = result
              .where((v) => filter.usageRights!.contains(v.usageRight))
              .toList();
        }

        return result;
      }

      throw Exception('Failed to load vehicles from server');
    } catch (e) {
      print('Error fetching vehicles: $e');
      // Временно возвращаем моковые данные или пустой список при ошибке?
      // Лучше выбросить ошибку и обработать на UI, но оставим возврат пустого списка или Exception
      throw e;
    }
  }

  Map<String, dynamic> _buildCarFilters(VehicleFilter filter) {
    final Map<String, dynamic> carQuery = {};

    if (filter.statuses != null && filter.statuses!.isNotEmpty) {
      final List<String> apiStatuses = [];
      for (var status in filter.statuses!) {
        switch (status) {
          case VehicleStatus.working:
            apiStatuses.add('working');
            break;
          case VehicleStatus.notWorking:
            apiStatuses.add('not_working');
            break;
          case VehicleStatus.service:
            apiStatuses.add('repairing');
            break;
          case VehicleStatus.noDriver:
            apiStatuses.add('no_driver');
            break;
          case VehicleStatus.preparation:
            apiStatuses.add('pending');
            break;
          case VehicleStatus.other:
            apiStatuses.add('unknown');
            break;
        }
      }
      carQuery['status'] = apiStatuses;
    }

    if (filter.categories != null && filter.categories!.isNotEmpty) {
      final List<String> apiCategories = [];
      for (var category in filter.categories!) {
        switch (category) {
          case VehicleCategory.econom:
            apiCategories.add('econom');
            break;
          case VehicleCategory.comfort:
            apiCategories.add('comfort');
            break;
          case VehicleCategory.comfortPlus:
            apiCategories.add('comfort_plus');
            break;
          case VehicleCategory.business:
            apiCategories.add('business');
            break;
          case VehicleCategory.minivan:
            apiCategories.add('minivan');
            break;
          case VehicleCategory.vip:
            apiCategories.add('vip');
            break;
          case VehicleCategory.wagon:
            apiCategories.add('wagon');
            break;
          case VehicleCategory.pool:
            apiCategories.add('pool');
            break;
          case VehicleCategory.start:
            apiCategories.add('start');
            break;
          case VehicleCategory.standart:
            apiCategories.add('standart');
            break;
          case VehicleCategory.ultimate:
            apiCategories.add('ultimate');
            break;
          case VehicleCategory.maybach:
            apiCategories.add('maybach');
            break;
          case VehicleCategory.promo:
            apiCategories.add('promo');
            break;
          case VehicleCategory.premiumVan:
            apiCategories.add('premium_van');
            break;
          case VehicleCategory.premiumSuv:
            apiCategories.add('premium_suv');
            break;
          case VehicleCategory.suv:
            apiCategories.add('suv');
            break;
          case VehicleCategory.personalDriver:
            apiCategories.add('personal_driver');
            break;
          case VehicleCategory.express:
            apiCategories.add('express');
            break;
          case VehicleCategory.cargo:
            apiCategories.add('cargo');
            break;
        }
      }
      carQuery['categories'] = apiCategories;
    }

    return carQuery;
  }
}
