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

      String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

      // Формируем payload для Yandex API (через наш бэкенд-прокси)
      final Map<String, dynamic> payload = {
        "limit": 1000,
        "offset": 0,
        "query": <String, dynamic>{
          "park": {
            "id": parkId,
            "car": _buildCarFilters(filter),
          }
        },
        "fields": {
          "car": [
            "id", "status", "amenities", "category", "callsign", "brand", 
            "model", "year", "color", "number", "registration_cert", "vin"
          ]
        }
      };

      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        payload['query']['text'] = filter.searchQuery;
      }

      final response = await _dio.post(
        '$baseUrl/api/vehicles/list',
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null && response.data['cars'] != null) {
        final List<dynamic> carsJson = response.data['cars'];
        
        var result = carsJson.map((e) => Vehicle.fromJson(e as Map<String, dynamic>)).toList();

        // Локальная фильтрация для полей, которых нет в API Яндекса
        if (filter.types != null && filter.types!.isNotEmpty) {
          result = result.where((v) => filter.types!.contains(v.type)).toList();
        }
        if (filter.owners != null && filter.owners!.isNotEmpty) {
          result = result.where((v) => filter.owners!.contains(v.owner)).toList();
        }
        if (filter.usageRights != null && filter.usageRights!.isNotEmpty) {
          result = result.where((v) => filter.usageRights!.contains(v.usageRight)).toList();
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

  Future<VehicleDetails> getVehicleDetails(String vehicleId) async {
    try {
      final parkId = await _secureStorage.getParkId();
      if (parkId == null || parkId.isEmpty) {
        throw Exception('Park ID is not available. Please login again.');
      }

      String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

      final response = await _dio.get(
        '$baseUrl/api/vehicles/car',
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

      String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

      print('Creating vehicle with payload: $payload');

      final response = await _dio.post(
        '$baseUrl/api/vehicles/create',
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

      String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

      print('Updating vehicle $vehicleId with payload: $payload');

      final response = await _dio.put(
        '$baseUrl/api/vehicles/car',
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

      String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

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

      // Обновляем статус для каждого автомобиля
      for (final vehicleId in vehicleIds) {
        // Сначала получаем полные данные автомобиля
        final details = await getVehicleDetails(vehicleId);
        
        // Формируем полный payload с обновленным статусом
        final Map<String, dynamic> payload = {
          'park_profile': {
            'status': apiStatus,
            'fuel_type': details.parkProfile?.fuelType,
            'is_park_property': details.parkProfile?.isParkProperty ?? false,
            'ownership_type': 'park',
            if (details.parkProfile?.categories != null && details.parkProfile!.categories!.isNotEmpty)
              'categories': details.parkProfile!.categories,
          },
          'vehicle_specifications': {
            'brand': details.specifications?.brand,
            'model': details.specifications?.model,
            'color': details.specifications?.color,
            'year': details.specifications?.year,
            'number': details.licenses?.licencePlateNumber,
            'vin': details.specifications?.vin,
            'registration_cert': details.licenses?.registrationCertificate,
            'transmission': details.specifications?.transmission,
          },
          'vehicle_licenses': {
            'licence_plate_number': details.licenses?.licencePlateNumber,
            'registration_certificate': details.licenses?.registrationCertificate,
            if (details.licenses?.licenceNumber != null)
              'licence_number': details.licenses!.licenceNumber,
          },
        };

        // Добавляем cargo если есть
        if (details.cargo != null &&
            (details.cargo!.cargoLoaders != null ||
             details.cargo!.carryingCapacity != null ||
             details.cargo!.cargoHoldDimensions != null)) {
          payload['cargo'] = {
            if (details.cargo!.cargoLoaders != null)
              'cargo_loaders': details.cargo!.cargoLoaders,
            if (details.cargo!.carryingCapacity != null)
              'carrying_capacity': details.cargo!.carryingCapacity,
            if (details.cargo!.cargoHoldDimensions != null)
              'cargo_hold_dimensions': {
                'length': details.cargo!.cargoHoldDimensions!.length,
                'height': details.cargo!.cargoHoldDimensions!.height,
                'width': details.cargo!.cargoHoldDimensions!.width,
              },
          };
        }

        // Добавляем child_safety если есть
        if (details.childSafety != null && details.childSafety!.boosterCount != null) {
          payload['child_safety'] = {
            'booster_count': details.childSafety!.boosterCount,
          };
        }

        await _dio.put(
          '$baseUrl/api/vehicles/car',
          queryParameters: {
            'vehicle_id': vehicleId,
          },
          data: payload,
        );
      }
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
          case VehicleStatus.working: apiStatuses.add('working'); break;
          case VehicleStatus.notWorking: apiStatuses.add('not_working'); break;
          case VehicleStatus.service: apiStatuses.add('repairing'); break;
          case VehicleStatus.noDriver: apiStatuses.add('no_driver'); break;
          case VehicleStatus.preparation: apiStatuses.add('pending'); break;
          case VehicleStatus.other: apiStatuses.add('unknown'); break;
        }
      }
      carQuery['status'] = apiStatuses;
    }

    if (filter.categories != null && filter.categories!.isNotEmpty) {
      final List<String> apiCategories = [];
      for (var category in filter.categories!) {
        switch (category) {
          case VehicleCategory.econom: apiCategories.add('econom'); break;
          case VehicleCategory.comfort: apiCategories.add('comfort'); break;
          case VehicleCategory.comfortPlus: apiCategories.add('comfort_plus'); break;
          case VehicleCategory.business: apiCategories.add('business'); break;
          case VehicleCategory.minivan: apiCategories.add('minivan'); break;
          case VehicleCategory.vip: apiCategories.add('vip'); break;
          case VehicleCategory.wagon: apiCategories.add('wagon'); break;
          case VehicleCategory.pool: apiCategories.add('pool'); break;
          case VehicleCategory.start: apiCategories.add('start'); break;
          case VehicleCategory.standart: apiCategories.add('standart'); break;
          case VehicleCategory.ultimate: apiCategories.add('ultimate'); break;
          case VehicleCategory.maybach: apiCategories.add('maybach'); break;
          case VehicleCategory.promo: apiCategories.add('promo'); break;
          case VehicleCategory.premiumVan: apiCategories.add('premium_van'); break;
          case VehicleCategory.premiumSuv: apiCategories.add('premium_suv'); break;
          case VehicleCategory.suv: apiCategories.add('suv'); break;
          case VehicleCategory.personalDriver: apiCategories.add('personal_driver'); break;
          case VehicleCategory.express: apiCategories.add('express'); break;
          case VehicleCategory.cargo: apiCategories.add('cargo'); break;
        }
      }
      carQuery['categories'] = apiCategories;
    }

    return carQuery;
  }
}
