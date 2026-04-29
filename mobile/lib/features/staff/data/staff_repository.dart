import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/staff/domain/staff.dart';
import 'package:mobile/shared/api/dio_provider.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return StaffRepository(dio: dio);
});

final staffListProvider = FutureProvider<List<Staff>>((ref) async {
  final repository = ref.watch(staffRepositoryProvider);
  return await repository.fetchStaff();
});

final staffProfileProvider = FutureProvider.family<Staff, String>((
  ref,
  profileId,
) async {
  final repository = ref.watch(staffRepositoryProvider);
  return await repository.fetchStaffProfile(profileId);
});

// Параметры для провайдера заказов водителя
class DriverOrdersParams {
  final String profileId;
  final int days;

  const DriverOrdersParams(this.profileId, this.days);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverOrdersParams &&
          runtimeType == other.runtimeType &&
          profileId == other.profileId &&
          days == other.days;

  @override
  int get hashCode => profileId.hashCode ^ days.hashCode;
}

final driverOrdersProvider =
    FutureProvider.family<Map<String, dynamic>, DriverOrdersParams>((
      ref,
      params,
    ) async {
      final repository = ref.watch(staffRepositoryProvider);

      // Рассчитываем даты внутри провайдера, чтобы избежать бесконечного цикла обновлений UI.
      // API Яндекса требует таймзону.
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: params.days));

      // Форматируем с нулями и добавляем таймзону
      String formatYandexDate(DateTime dt) {
        return '${dt.toIso8601String().split('.')[0]}+03:00'; // Упрощенный формат для примера
      }

      final fromStr = formatYandexDate(startDate);
      final toStr = formatYandexDate(now);

      final data = await repository.fetchDriverOrders(
        params.profileId,
        fromStr,
        toStr,
      );
      return data;
    });

final carInfoProvider = FutureProvider.family<Map<String, dynamic>?, String>((
  ref,
  carId,
) async {
  if (carId.isEmpty) return null;
  final repository = ref.watch(staffRepositoryProvider);
  final data = await repository.fetchCarInfo(carId);
  return data;
});

final transactionCategoriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final repository = ref.watch(staffRepositoryProvider);
      return await repository.fetchTransactionCategories();
    });

final driverDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, driverId) async {
      final repository = ref.watch(staffRepositoryProvider);
      return await repository.fetchDriverDetails(driverId);
    });

class StaffRepository {
  final Dio _dio;

  StaffRepository({required Dio dio}) : _dio = dio;

  Future<List<Staff>> fetchStaff({
    int limit = 500,
    int offset = 0,
    int retries = 2,
  }) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        final response = await _dio.get(
          '/api/staff/list',
          queryParameters: {'limit': limit, 'offset': offset},
        );

        final data = response.data;
        if (data != null && data is List) {
          return data.map((json) => Staff.fromContractorJson(json)).toList();
        } else if (data != null && data['contractors'] != null) {
          final List<dynamic> profiles = data['contractors'];
          return profiles
              .map((json) => Staff.fromContractorJson(json))
              .toList();
        } else if (data != null && data['users'] != null) {
          final List<dynamic> profiles = data['users'];
          return profiles.map((json) => Staff.fromUserJson(json)).toList();
        }
        return [];
      } catch (e, stack) {
        print('Error in fetchStaff: $e\n$stack');
        if (attempt == retries || e is TypeError) {
          throw Exception('Failed to load staff: $e');
        }
      }
    }
    return [];
  }

  Future<Staff> fetchStaffProfile(String profileId) async {
    try {
      final response = await _dio.get(
        '/api/staff/profile',
        queryParameters: {'contractor_profile_id': profileId},
      );

      final data = response.data;
      if (data != null) {
        return Staff.fromContractorDataJson(data);
      }
      throw Exception('Пустой ответ от сервера');
    } catch (e) {
      throw Exception('Failed to load staff profile: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTransactionCategories() async {
    try {
      final response = await _dio.get('/api/staff/categories');
      final data = response.data;
      if (data != null && data['categories'] != null) {
        return List<Map<String, dynamic>>.from(data['categories']);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load transaction categories: $e');
    }
  }

  Future<Map<String, dynamic>> createTransaction({
    required String contractorProfileId,
    required String amount,
    required String kind,
    String? categoryId,
    String? balanceMin,
    String? receiptCondition,
    String? description,
    String? feeAmount,
    String? childDriverId,
    String? objectId,
    String? objectType,
    String? parkFee,
    String? fuelValue,
    String? fuelUnits,
    String? reason,
  }) async {
    try {
      // Check if this is a custom category
      final isCustomCategory =
          categoryId != null &&
          categoryId.startsWith('partner_service_manual_');

      final requestBody = <String, dynamic>{
        'contractor_profile_id': contractorProfileId,
        'amount': amount,
      };

      if (isCustomCategory) {
        // For custom categories: category_id at top level, no data object
        requestBody['category_id'] = categoryId;
      } else {
        // For system categories: use data object with kind
        final dataMap = <String, dynamic>{'kind': kind};

        // Add fee_amount if provided (convert positive to negative for API)
        if (feeAmount != null && feeAmount.isNotEmpty) {
          final feeValue = double.tryParse(feeAmount);
          if (feeValue != null && feeValue > 0) {
            dataMap['fee_amount'] = (-feeValue).toStringAsFixed(4);
          }
        }

        // Add receipt_condition to data if provided
        if (receiptCondition != null && receiptCondition.isNotEmpty) {
          dataMap['receipt_condition'] = receiptCondition;
        }

        // Add child_driver_id for referal program
        if (childDriverId != null && childDriverId.isNotEmpty) {
          dataMap['child_driver_id'] = childDriverId;
        }

        // Add object for rent (vehicle information)
        if (objectId != null &&
            objectId.isNotEmpty &&
            objectType != null &&
            objectType.isNotEmpty) {
          dataMap['object'] = {
            'object_type': objectType,
            'object_id': objectId,
          };
        }

        // Add park_fee for fine (convert positive to negative for API)
        if (parkFee != null && parkFee.isNotEmpty) {
          final parkFeeValue = double.tryParse(parkFee);
          if (parkFeeValue != null && parkFeeValue > 0) {
            dataMap['park_fee'] = (-parkFeeValue).toStringAsFixed(4);
          }
        }

        // Add fuel value and units for fuel category
        if (fuelValue != null && fuelValue.isNotEmpty) {
          dataMap['value'] = fuelValue;
        }
        if (fuelUnits != null && fuelUnits.isNotEmpty) {
          dataMap['units'] = fuelUnits;
        }

        // Add reason for other category
        if (reason != null && reason.isNotEmpty) {
          dataMap['reason'] = reason;
        }

        requestBody['data'] = dataMap;
      }

      // Add condition with balance_min if provided (must be a valid number with max 4 decimal places)
      if (balanceMin != null && balanceMin.isNotEmpty) {
        final balanceValue = double.tryParse(balanceMin);
        if (balanceValue != null) {
          requestBody['condition'] = {
            'balance_min': balanceValue.toStringAsFixed(4),
          };
        }
      }

      // Add description (comment) if provided
      if (description != null && description.isNotEmpty) {
        requestBody['description'] = description;
      }

      final response = await _dio.post(
        '/api/staff/transaction',
        data: requestBody,
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  Future<Map<String, dynamic>> fetchDriverOrders(
    String profileId,
    String from,
    String to,
  ) async {
    try {
      final response = await _dio.get(
        '/api/staff/orders',
        queryParameters: {
          'contractor_profile_id': profileId,
          'from': from,
          'to': to,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception('Failed to load driver orders: $e');
    }
  }

  Future<Map<String, dynamic>> fetchCarInfo(String carId) async {
    try {
      final response = await _dio.get(
        '/api/staff/car',
        queryParameters: {'car_id': carId},
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception('Failed to load car info: $e');
    }
  }

  Future<Map<String, dynamic>> fetchDriverDetails(String driverId) async {
    try {
      final response = await _dio.post(
        '/api/staff/details',
        data: {'driver_id': driverId},
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception('Failed to load driver details: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchVehicleSuggestions({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/api/staff/vehicles/suggest',
        queryParameters: {'limit': limit},
      );
      final data = response.data;
      if (data != null && data['items'] != null) {
        return List<Map<String, dynamic>>.from(data['items']);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load vehicle suggestions: $e');
    }
  }
}
