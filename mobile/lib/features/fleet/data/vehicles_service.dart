import 'package:dio/dio.dart';
import 'package:mobile/features/fleet/domain/vehicle.dart';
import 'package:mobile/features/fleet/domain/vehicle_details.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

      // Формируем payload для нового Yandex API
      // https://fleet.yandex.ru/api/fleet/vehicles-manager/v1/vehicles/list
      final Map<String, dynamic> carQuery = {
        "status": _mapStatuses(filter.statuses),
        "categories": _mapCategories(filter.categories),
        "owner": "park",
      };

      final vehicleTypes = _mapVehicleTypes(filter.types);
      if (vehicleTypes.isNotEmpty) {
        carQuery["vehicle_types"] = vehicleTypes;
      }

      final Map<String, dynamic> queryMap = {"car": carQuery};

      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        queryMap["text"] = filter.searchQuery;
      }

      final Map<String, dynamic> payload = {
        "query": queryMap,
        "limit": 30,
      };

      final response = await _dio.post('/api/vehicles/list', data: payload);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final List<dynamic>? carsJson = (data['cars'] ?? data['vehicles']) as List<dynamic>?;
        if (carsJson == null) {
          throw Exception('Unexpected response shape from server');
        }

        var result = carsJson
            .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
            .toList();

        // Локальная фильтрация для полей, которых нет в фильтре API
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
      throw e;
    }
  }

  List<String> _mapVehicleTypes(List<VehicleType>? types) {
    if (types == null || types.isEmpty) return const [];
    return types.map((t) {
      switch (t) {
        case VehicleType.automobile:
          return 'car';
        case VehicleType.motorcycle:
          return 'motorcycle';
        case VehicleType.rickshaw:
          return 'rickshaw';
      }
    }).toList();
  }

  List<String> _mapStatuses(List<VehicleStatus>? statuses) {
    if (statuses == null || statuses.isEmpty) return const [];
    return statuses.map((s) {
      switch (s) {
        case VehicleStatus.working:
          return 'working';
        case VehicleStatus.notWorking:
          return 'not_working';
        case VehicleStatus.service:
          return 'repairing';
        case VehicleStatus.noDriver:
          return 'no_driver';
        case VehicleStatus.preparation:
          return 'pending';
        case VehicleStatus.other:
          return 'unknown';
      }
    }).toList();
  }

  List<String> _mapCategories(List<VehicleCategory>? categories) {
    if (categories == null || categories.isEmpty) return const [];
    return categories.map((c) {
      switch (c) {
        case VehicleCategory.econom:
          return 'econom';
        case VehicleCategory.comfort:
          return 'comfort';
        case VehicleCategory.comfortPlus:
          return 'comfort_plus';
        case VehicleCategory.business:
          return 'business';
        case VehicleCategory.minivan:
          return 'minivan';
        case VehicleCategory.vip:
          return 'vip';
        case VehicleCategory.wagon:
          return 'wagon';
        case VehicleCategory.pool:
          return 'pool';
        case VehicleCategory.start:
          return 'start';
        case VehicleCategory.standart:
          return 'standart';
        case VehicleCategory.ultimate:
          return 'ultimate';
        case VehicleCategory.maybach:
          return 'maybach';
        case VehicleCategory.promo:
          return 'promo';
        case VehicleCategory.premiumVan:
          return 'premium_van';
        case VehicleCategory.premiumSuv:
          return 'premium_suv';
        case VehicleCategory.suv:
          return 'suv';
        case VehicleCategory.personalDriver:
          return 'personal_driver';
        case VehicleCategory.express:
          return 'express';
        case VehicleCategory.cargo:
          return 'cargo';
      }
    }).toList();
  }

  Future<VehicleDetails> getVehicleDetails(String vehicleId) async {
    try {
      final parkId = await _secureStorage.getParkId();
      if (parkId == null || parkId.isEmpty) {
        throw Exception('Park ID is not available. Please login again.');
      }

      final response = await _dio.get(
        '/api/vehicles/car',
        queryParameters: {
          'vehicle_id': vehicleId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return VehicleDetails.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to load vehicle details');
    } catch (e) {
      print('Error fetching vehicle details: $e');
      throw e;
    }
  }

  Future<String> createVehicle(Map<String, dynamic> payload) async {
    try {
      final parkId = await _secureStorage.getParkId();
      if (parkId == null || parkId.isEmpty) {
        throw Exception('Park ID is not available. Please login again.');
      }

      final response = await _dio.post(
        '/api/vehicles/create',
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['vehicle_id'] as String;
      }

      throw Exception('Failed to create vehicle');
    } on DioException catch (e) {
      print('DioException creating vehicle:');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      print('Request data: ${e.requestOptions.data}');
      
      // Извлекаем и обрабатываем ошибки от API
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map) {
          final code = errorData['code'] as String?;
          final message = errorData['message'] as String?;
          
          // Обрабатываем специфичные коды ошибок
          final userMessage = _getErrorMessage(code, message);
          throw Exception(userMessage);
        }
      }
      
      throw Exception('Не удалось создать автомобиль: ${e.message}');
    } catch (e) {
      print('Error creating vehicle: $e');
      throw e;
    }
  }

  Future<void> updateVehicle(String vehicleId, Map<String, dynamic> payload) async {
    try {
      final parkId = await _secureStorage.getParkId();
      if (parkId == null || parkId.isEmpty) {
        throw Exception('Park ID is not available. Please login again.');
      }

      final response = await _dio.put(
        '/api/vehicles/car',
        queryParameters: {
          'vehicle_id': vehicleId,
        },
        data: payload,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update vehicle');
      }
    } on DioException catch (e) {
      print('DioException updating vehicle:');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      print('Request data: ${e.requestOptions.data}');
      
      // Извлекаем и обрабатываем ошибки от API
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map) {
          final code = errorData['code'] as String?;
          final message = errorData['message'] as String?;
          
          // Обрабатываем специфичные коды ошибок
          final userMessage = _getErrorMessage(code, message);
          throw Exception(userMessage);
        }
      }
      
      throw Exception('Не удалось обновить автомобиль: ${e.message}');
    } catch (e) {
      print('Error updating vehicle: $e');
      throw e;
    }
  }

  Future<void> updateVehiclesStatus(List<String> vehicleIds, VehicleStatus status) async {
    try {
      final parkId = await _secureStorage.getParkId();
      if (parkId == null || parkId.isEmpty) {
        throw Exception('Park ID is not available. Please login again.');
      }

      // Преобразуем статус в формат API
      String apiStatus;
      switch (status) {
        case VehicleStatus.working:
          apiStatus = 'working';
          break;
        case VehicleStatus.notWorking:
          apiStatus = 'not_working';
          break;
        case VehicleStatus.service:
          apiStatus = 'repairing';
          break;
        case VehicleStatus.noDriver:
          apiStatus = 'no_driver';
          break;
        case VehicleStatus.preparation:
          apiStatus = 'pending';
          break;
        case VehicleStatus.other:
          apiStatus = 'unknown';
          break;
      }

      // Формируем payload для нового API fleet-operations/vehicle-status
      final Map<String, dynamic> payload = {
        'filters': {
          'car': {
            'status': <String>[],
            'categories': <String>[],
            'owner': 'park',
            'car_ids': vehicleIds,
          },
        },
        'action': {
          'status': apiStatus,
        },
      };

      await _dio.post('/api/vehicles/status', data: payload);
    } on DioException catch (e) {
      print('DioException updating vehicles status:');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');

      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map) {
          final code = errorData['code'] as String?;
          final message = errorData['message'] as String?;
          final userMessage = _getErrorMessage(code, message);
          throw Exception(userMessage);
        }
      }

      throw Exception('Не удалось обновить статус автомобилей: ${e.message}');
    } catch (e) {
      print('Error updating vehicles status: $e');
      throw e;
    }
  }

  String _getErrorMessage(String? code, String? apiMessage) {
    switch (code) {
      case 'invalid_car_model':
        return 'Указанная модель автомобиля не найдена в базе Yandex. Проверьте правильность написания модели.';
      case 'invalid_number':
        return 'Неверный формат государственного номера. Используйте латинские буквы и цифры (например: A123BC777).';
      case 'invalid_vin':
        return 'Неверный формат VIN. VIN должен содержать 17 символов (латинские буквы и цифры, без I, O, Q).';
      case 'invalid_fuel_type':
        return 'Неверный тип топлива. Допустимые значения: petrol, methane, propane, electricity.';
      case 'invalid_transmission':
        return 'Неверный тип коробки передач. Допустимые значения: mechanical, automatic, robotic, variator.';
      case 'invalid_color':
        return 'Неверный цвет. Используйте русские названия цветов из списка (Белый, Черный, Серый и т.д.).';
      case 'invalid_year':
        return 'Неверный год выпуска. Год должен быть от 1970 до текущего года.';
      case 'duplicate_number':
        return 'Автомобиль с таким государственным номером уже существует в системе.';
      case 'duplicate_vin':
        return 'Автомобиль с таким VIN уже существует в системе.';
      case 'missing_required_field':
        return 'Не заполнены обязательные поля. Проверьте форму.';
      default:
        // Возвращаем оригинальное сообщение от API, если код неизвестен
        return apiMessage ?? 'Ошибка при создании автомобиля. Проверьте введенные данные.';
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

  Future<List<String>> getBrands() async {
    try {
      final response = await _dio.get('/api/vehicles/brands');

      if (response.statusCode == 200 && response.data != null) {
        final brands = (response.data['brands'] as List<dynamic>)
            .map((e) => (e as Map<String, dynamic>)['name'] as String)
            .toList();
        return brands;
      }

      throw Exception('Failed to load brands');
    } catch (e) {
      print('Error fetching brands: $e');
      throw e;
    }
  }

  Future<List<String>> getModels(String brand) async {
    try {
      final response = await _dio.get(
        '/api/vehicles/models',
        queryParameters: {'brand': brand},
      );

      if (response.statusCode == 200 && response.data != null) {
        final models = (response.data['models'] as List<dynamic>)
            .map((e) => (e as Map<String, dynamic>)['name'] as String)
            .toList();
        return models;
      }

      throw Exception('Failed to load models');
    } catch (e) {
      print('Error fetching models: $e');
      throw e;
    }
  }

  Future<List<String>> getCategories(String vehicleId) async {
    try {
      final response = await _dio.get(
        '/api/vehicles/categories',
        queryParameters: {'vehicle_id': vehicleId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final categories = (response.data['categories'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
        return categories;
      }

      throw Exception('Failed to load categories');
    } catch (e) {
      print('Error fetching categories: $e');
      throw e;
    }
  }

  Future<void> updateCategories(String vehicleId, List<String> categories) async {
    try {
      await _dio.post(
        '/api/vehicles/categories',
        queryParameters: {'vehicle_id': vehicleId},
        data: {'categories': categories},
      );
    } catch (e) {
      print('Error updating categories: $e');
      throw e;
    }
  }

  Future<Map<String, String>> getCarCategories() async {
    try {
      final response = await _dio.post(
        '/api/vehicles/references',
        data: {'references': ['car_categories']},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> categories = response.data['car_categories'] as List<dynamic>;
        final Map<String, String> result = {};
        for (final cat in categories) {
          final map = cat as Map<String, dynamic>;
          final id = map['id'] as String;
          final name = (map['name'] as String?) ?? id;
          if (id.isNotEmpty) {
            result[id] = name;
          }
        }
        return result;
      }

      throw Exception('Failed to load car categories');
    } catch (e) {
      print('Error fetching car categories: $e');
      throw e;
    }
  }
}
