import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/data/vehicles_service.dart';
import 'package:mobile/features/fleet/domain/vehicle_details.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

class EditVehicleFormData {
  final String vehicleId;
  final bool isTruck;
  final VehicleDetails originalDetails; // Сохраняем оригинальные данные

  // Основные данные
  final String sts;
  final String plateNumber;
  final String brand;
  final String year;
  final String stsIssueDate;
  final String vin;
  final String model;
  final String bodyNumber;
  final String color;
  final String fuelType;
  final String transmission;

  // Дополнительные данные
  final String parkingAddress;
  final bool hasAirConditioner;
  final String additionalInfo;

  // Флаг для отображения ошибок
  final bool showValidationErrors;

  const EditVehicleFormData({
    required this.vehicleId,
    required this.originalDetails,
    this.isTruck = false,
    this.sts = '',
    this.plateNumber = '',
    this.brand = '',
    this.year = '',
    this.stsIssueDate = '',
    this.vin = '',
    this.model = '',
    this.bodyNumber = '',
    this.color = '',
    this.fuelType = '',
    this.transmission = '',
    this.parkingAddress = '',
    this.hasAirConditioner = false,
    this.additionalInfo = '',
    this.showValidationErrors = false,
  });

  // Создание из VehicleDetails
  factory EditVehicleFormData.fromVehicleDetails(
    String vehicleId,
    VehicleDetails details,
  ) {
    final specs = details.specifications;
    final licenses = details.licenses;
    final profile = details.parkProfile;

    // Определяем тип автомобиля по категориям
    // categories содержит список категорий/тарифов конкретного автомобиля
    // Если есть категория 'cargo', значит это грузовой автомобиль
    final isTruck = profile?.categories?.contains('cargo') ?? false;
    
    return EditVehicleFormData(
      vehicleId: vehicleId,
      originalDetails: details,
      isTruck: isTruck,
      sts: licenses?.registrationCertificate ?? '',
      plateNumber: licenses?.licencePlateNumber ?? '',
      brand: specs?.brand ?? '',
      year: specs?.year?.toString() ?? '',
      stsIssueDate: '', // API не возвращает дату выдачи СТС
      vin: specs?.vin ?? '',
      model: specs?.model ?? '',
      bodyNumber: specs?.bodyNumber ?? '',
      color: specs?.color ?? '',
      fuelType: _mapFuelTypeFromApi(profile?.fuelType ?? ''),
      transmission: _mapTransmissionFromApi(specs?.transmission ?? ''),
      parkingAddress: '', // API не возвращает адрес парковки
      hasAirConditioner: profile?.amenities?.contains('conditioner') ?? false,
      additionalInfo: profile?.comment ?? '',
    );
  }

  static String _mapFuelTypeFromApi(String apiValue) {
    switch (apiValue.toLowerCase()) {
      case 'petrol':
        return 'Бензин';
      case 'methane':
        return 'Метан';
      case 'propane':
        return 'Пропан';
      case 'electricity':
        return 'Электричество';
      default:
        return 'Бензин';
    }
  }

  static String _mapTransmissionFromApi(String apiValue) {
    switch (apiValue.toLowerCase()) {
      case 'mechanical':
        return 'Механическая';
      case 'automatic':
        return 'Автоматическая';
      case 'robotic':
        return 'Роботизированная';
      case 'variator':
        return 'Вариатор';
      default:
        return 'Механическая';
    }
  }

  EditVehicleFormData copyWith({
    String? vehicleId,
    VehicleDetails? originalDetails,
    bool? isTruck,
    String? sts,
    String? plateNumber,
    String? brand,
    String? year,
    String? stsIssueDate,
    String? vin,
    String? model,
    String? bodyNumber,
    String? color,
    String? fuelType,
    String? transmission,
    String? parkingAddress,
    bool? hasAirConditioner,
    String? additionalInfo,
    bool? showValidationErrors,
  }) {
    return EditVehicleFormData(
      vehicleId: vehicleId ?? this.vehicleId,
      originalDetails: originalDetails ?? this.originalDetails,
      isTruck: isTruck ?? this.isTruck,
      sts: sts ?? this.sts,
      plateNumber: plateNumber ?? this.plateNumber,
      brand: brand ?? this.brand,
      year: year ?? this.year,
      stsIssueDate: stsIssueDate ?? this.stsIssueDate,
      vin: vin ?? this.vin,
      model: model ?? this.model,
      bodyNumber: bodyNumber ?? this.bodyNumber,
      color: color ?? this.color,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      parkingAddress: parkingAddress ?? this.parkingAddress,
      hasAirConditioner: hasAirConditioner ?? this.hasAirConditioner,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
    );
  }

  // Проверка конкретных полей
  bool isFieldValid(String fieldName) {
    switch (fieldName) {
      case 'sts':
        return sts.isNotEmpty;
      case 'plateNumber':
        return plateNumber.isNotEmpty;
      case 'brand':
        return brand.isNotEmpty;
      case 'year':
        return year.isNotEmpty && _isValidYear(year);
      case 'vin':
        return vin.isNotEmpty && _isValidVIN(vin);
      case 'model':
        return model.isNotEmpty;
      case 'color':
        return color.isNotEmpty;
      case 'fuelType':
        return fuelType.isNotEmpty;
      case 'transmission':
        return transmission.isNotEmpty;
      default:
        return true;
    }
  }

  bool _isValidVIN(String value) {
    if (value.length != 17) return false;
    final regex = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$', caseSensitive: false);
    return regex.hasMatch(value);
  }

  bool _isValidYear(String value) {
    final year = int.tryParse(value);
    if (year == null) return false;
    final currentYear = DateTime.now().year;
    return year >= 1970 && year <= currentYear;
  }

  String? getFieldError(String fieldName) {
    if (!showValidationErrors) return null;

    switch (fieldName) {
      case 'sts':
        if (sts.isEmpty) return 'Обязательное поле';
        return null;
      case 'plateNumber':
        if (plateNumber.isEmpty) return 'Обязательное поле';
        return null;
      case 'vin':
        if (vin.isEmpty) return 'Обязательное поле';
        if (vin.length != 17) return 'VIN должен содержать 17 символов';
        if (!_isValidVIN(vin)) return 'Неверный формат VIN';
        return null;
      case 'year':
        if (year.isEmpty) return 'Обязательное поле';
        if (!_isValidYear(year)) return 'Год от 1970 до ${DateTime.now().year}';
        return null;
      default:
        if (!isFieldValid(fieldName)) return 'Обязательное поле';
        return null;
    }
  }

  bool get isValid {
    return sts.isNotEmpty &&
        plateNumber.isNotEmpty &&
        brand.isNotEmpty &&
        year.isNotEmpty &&
        vin.isNotEmpty &&
        model.isNotEmpty &&
        color.isNotEmpty &&
        fuelType.isNotEmpty &&
        transmission.isNotEmpty;
  }

  Map<String, dynamic> toYandexApiJson() {
    final Map<String, dynamic> payload = {
      'park_profile': {
        'status': 'working',
        'fuel_type': _mapFuelType(fuelType),
        'is_park_property': true,
        'ownership_type': 'park',
        // Копируем categories из оригинальных данных
        if (originalDetails.parkProfile?.categories != null)
          'categories': originalDetails.parkProfile!.categories,
      },
      'vehicle_licenses': {
        'licence_plate_number': _transliteratePlateNumber(plateNumber),
        'registration_certificate': _transliterateToLatin(sts),
      },
      'vehicle_specifications': {
        'brand': brand,
        'model': model,
        'color': _mapColor(color),
        'year': int.tryParse(year) ?? 0,
        'transmission': _mapTransmission(transmission),
        'vin': vin.toUpperCase(),
      },
    };

    if (bodyNumber.isNotEmpty) {
      payload['vehicle_specifications']['body_number'] = bodyNumber;
    }

    if (hasAirConditioner) {
      payload['park_profile']['amenities'] = ['conditioner'];
    }

    if (additionalInfo.isNotEmpty) {
      payload['park_profile']['comment'] = additionalInfo;
    }

    // Копируем cargo из оригинальных данных только если это грузовой автомобиль
    // И только если cargo действительно содержит данные
    if (isTruck && originalDetails.cargo != null) {
      final cargo = originalDetails.cargo!;
      
      // Проверяем, есть ли хоть какие-то значимые данные в cargo
      final hasCargoLoaders = cargo.cargoLoaders != null && cargo.cargoLoaders! > 0;
      final hasCarryingCapacity = cargo.carryingCapacity != null && cargo.carryingCapacity! > 0;
      final hasDimensions = cargo.cargoHoldDimensions != null &&
          (cargo.cargoHoldDimensions!.height != null ||
           cargo.cargoHoldDimensions!.length != null ||
           cargo.cargoHoldDimensions!.width != null);
      
      // Отправляем cargo только если есть хоть одно значимое поле
      if (hasCargoLoaders || hasCarryingCapacity || hasDimensions) {
        payload['cargo'] = {
          if (cargo.cargoLoaders != null) 'cargo_loaders': cargo.cargoLoaders,
          if (cargo.carryingCapacity != null) 'carrying_capacity': cargo.carryingCapacity,
          if (cargo.cargoHoldDimensions != null)
            'cargo_hold_dimensions': {
              if (cargo.cargoHoldDimensions!.height != null)
                'height': cargo.cargoHoldDimensions!.height,
              if (cargo.cargoHoldDimensions!.length != null)
                'length': cargo.cargoHoldDimensions!.length,
              if (cargo.cargoHoldDimensions!.width != null)
                'width': cargo.cargoHoldDimensions!.width,
            },
        };
      }
    }

    // Копируем child_safety из оригинальных данных
    final childSafety = originalDetails.childSafety;
    if (childSafety != null) {
      payload['child_safety'] = {
        if (childSafety.boosterCount != null) 'booster_count': childSafety.boosterCount,
      };
    }

    return payload;
  }

  String _mapFuelType(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case 'бензин':
        return 'petrol';
      case 'метан':
        return 'methane';
      case 'пропан':
        return 'propane';
      case 'электричество':
        return 'electricity';
      default:
        return 'petrol';
    }
  }

  String _mapColor(String color) {
    return color; // Цвета уже в правильном формате
  }

  String _mapTransmission(String transmission) {
    switch (transmission.toLowerCase()) {
      case 'механическая':
        return 'mechanical';
      case 'автоматическая':
        return 'automatic';
      case 'роботизированная':
        return 'robotic';
      case 'вариатор':
        return 'variator';
      default:
        return 'mechanical';
    }
  }

  String _transliteratePlateNumber(String text) {
    const Map<String, String> translitMap = {
      'А': 'A',
      'а': 'A',
      'В': 'B',
      'в': 'B',
      'Е': 'E',
      'е': 'E',
      'К': 'K',
      'к': 'K',
      'М': 'M',
      'м': 'M',
      'Н': 'H',
      'н': 'H',
      'О': 'O',
      'о': 'O',
      'Р': 'P',
      'р': 'P',
      'С': 'C',
      'с': 'C',
      'Т': 'T',
      'т': 'T',
      'У': 'Y',
      'у': 'Y',
      'Х': 'X',
      'х': 'X',
    };

    return text
        .split('')
        .map((char) => translitMap[char] ?? char)
        .join()
        .toUpperCase();
  }

  String _transliterateToLatin(String text) {
    const Map<String, String> translitMap = {
      'А': 'A',
      'а': 'a',
      'Б': 'B',
      'б': 'b',
      'В': 'V',
      'в': 'v',
      'Г': 'G',
      'г': 'g',
      'Д': 'D',
      'д': 'd',
      'Е': 'E',
      'е': 'e',
      'Ё': 'E',
      'ё': 'e',
      'Ж': 'Zh',
      'ж': 'zh',
      'З': 'Z',
      'з': 'z',
      'И': 'I',
      'и': 'i',
      'Й': 'Y',
      'й': 'y',
      'К': 'K',
      'к': 'k',
      'Л': 'L',
      'л': 'l',
      'М': 'M',
      'м': 'm',
      'Н': 'N',
      'н': 'n',
      'О': 'O',
      'о': 'o',
      'П': 'P',
      'п': 'p',
      'Р': 'R',
      'р': 'r',
      'С': 'S',
      'с': 's',
      'Т': 'T',
      'т': 't',
      'У': 'U',
      'у': 'u',
      'Ф': 'F',
      'ф': 'f',
      'Х': 'Kh',
      'х': 'kh',
      'Ц': 'Ts',
      'ц': 'ts',
      'Ч': 'Ch',
      'ч': 'ch',
      'Ш': 'Sh',
      'ш': 'sh',
      'Щ': 'Shch',
      'щ': 'shch',
      'Ъ': '',
      'ъ': '',
      'Ы': 'Y',
      'ы': 'y',
      'Ь': '',
      'ь': '',
      'Э': 'E',
      'э': 'e',
      'Ю': 'Yu',
      'ю': 'yu',
      'Я': 'Ya',
      'я': 'ya',
    };

    return text.split('').map((char) => translitMap[char] ?? char).join();
  }
}

class EditVehicleFormNotifier extends Notifier<EditVehicleFormData?> {
  @override
  EditVehicleFormData? build() {
    return null;
  }

  void initialize(String vehicleId, VehicleDetails details) {
    state = EditVehicleFormData.fromVehicleDetails(vehicleId, details);
  }

  void updateField({
    String? sts,
    String? plateNumber,
    String? brand,
    String? year,
    String? stsIssueDate,
    String? vin,
    String? model,
    String? bodyNumber,
    String? color,
    String? fuelType,
    String? transmission,
    String? parkingAddress,
    String? additionalInfo,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      sts: sts,
      plateNumber: plateNumber,
      brand: brand,
      year: year,
      stsIssueDate: stsIssueDate,
      vin: vin,
      model: model,
      bodyNumber: bodyNumber,
      color: color,
      fuelType: fuelType,
      transmission: transmission,
      parkingAddress: parkingAddress,
      additionalInfo: additionalInfo,
    );
  }

  void setIsTruck(bool isTruck) {
    if (state == null) return;
    state = state!.copyWith(isTruck: isTruck);
  }

  void setHasAirConditioner(bool hasAirConditioner) {
    if (state == null) return;
    state = state!.copyWith(hasAirConditioner: hasAirConditioner);
  }

  void reset() {
    state = null;
  }

  Future<String?> submit() async {
    if (state == null) return 'Нет данных для сохранения';

    state = state!.copyWith(showValidationErrors: true);

    if (!state!.isValid) {
      return 'Заполните все обязательные поля';
    }

    try {
      final dio = ref.read(dioProvider);
      final secureStorage = ref.read(secureStorageServiceProvider);
      final vehiclesService = VehiclesService(dio, secureStorage);

      final payload = state!.toYandexApiJson();
      await vehiclesService.updateVehicle(state!.vehicleId, payload);

      return null; // успех
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        return errorMessage.substring('Exception: '.length);
      }
      return errorMessage;
    }
  }
}

final editVehicleFormProvider =
    NotifierProvider<EditVehicleFormNotifier, EditVehicleFormData?>(
  () => EditVehicleFormNotifier(),
);
