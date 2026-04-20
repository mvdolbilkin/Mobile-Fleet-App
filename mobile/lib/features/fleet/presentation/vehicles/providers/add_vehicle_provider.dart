import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/data/vehicles_service.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

class AddVehicleFormData {
  final int step;
  final bool isTruck;

  // Шаг 1: Основные данные
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

  // Шаг 2: Дополнительные данные (и грузовые параметры)
  final String length;
  final String height;
  final String width;
  final String capacity;
  final bool isParkVehicle;
  final bool hasAirConditioner;
  final String callsign;

  // Флаг для отображения ошибок
  final bool showValidationErrors;

  const AddVehicleFormData({
    this.step = 1,
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
    this.length = '',
    this.height = '',
    this.width = '',
    this.capacity = '',
    this.isParkVehicle = true,
    this.hasAirConditioner = false,
    this.callsign = '',
    this.showValidationErrors = false,
  });

  AddVehicleFormData copyWith({
    int? step,
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
    String? length,
    String? height,
    String? width,
    String? capacity,
    bool? isParkVehicle,
    bool? hasAirConditioner,
    String? callsign,
    bool? showValidationErrors,
  }) {
    return AddVehicleFormData(
      step: step ?? this.step,
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
      length: length ?? this.length,
      height: height ?? this.height,
      width: width ?? this.width,
      capacity: capacity ?? this.capacity,
      isParkVehicle: isParkVehicle ?? this.isParkVehicle,
      hasAirConditioner: hasAirConditioner ?? this.hasAirConditioner,
      callsign: callsign ?? this.callsign,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
    );
  }

  // Проверка конкретных полей
  bool isFieldValid(String fieldName) {
    switch (fieldName) {
      case 'sts': return sts.isNotEmpty && _isValidLatinOrDigits(sts);
      case 'plateNumber': return plateNumber.isNotEmpty && _isValidPlateNumber(plateNumber);
      case 'brand': return brand.isNotEmpty;
      case 'year': return year.isNotEmpty && _isValidYear(year);
      case 'vin': return vin.isNotEmpty && _isValidVIN(vin);
      case 'model': return model.isNotEmpty;
      case 'color': return color.isNotEmpty;
      case 'fuelType': return fuelType.isNotEmpty;
      case 'transmission': return transmission.isNotEmpty;
      case 'length': return length.isNotEmpty && _isValidNumber(length);
      case 'height': return height.isNotEmpty && _isValidNumber(height);
      case 'width': return width.isNotEmpty && _isValidNumber(width);
      case 'capacity': return capacity.isNotEmpty && _isValidNumber(capacity);
      default: return true;
    }
  }

  // Валидация номера (только латиница и цифры)
  bool _isValidPlateNumber(String value) {
    final regex = RegExp(r'^[A-Z0-9]+$', caseSensitive: false);
    return regex.hasMatch(value);
  }

  // Валидация VIN (17 символов, латиница и цифры, без I, O, Q)
  bool _isValidVIN(String value) {
    if (value.length != 17) return false;
    final regex = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$', caseSensitive: false);
    return regex.hasMatch(value);
  }

  // Валидация года (4 цифры, от 1970 до текущего года)
  bool _isValidYear(String value) {
    final year = int.tryParse(value);
    if (year == null) return false;
    final currentYear = DateTime.now().year;
    return year >= 1970 && year <= currentYear;
  }

  // Валидация числа
  bool _isValidNumber(String value) {
    return int.tryParse(value) != null;
  }

  // Проверка на латиницу и цифры
  bool _isValidLatinOrDigits(String value) {
    final regex = RegExp(r'^[A-Z0-9]+$', caseSensitive: false);
    return regex.hasMatch(value);
  }

  // Получение сообщения об ошибке для поля
  String? getFieldError(String fieldName) {
    if (!showValidationErrors) return null;
    
    switch (fieldName) {
      case 'sts':
        if (sts.isEmpty) return 'Обязательное поле';
        if (!_isValidLatinOrDigits(sts)) return 'Только латиница и цифры';
        return null;
      case 'plateNumber':
        if (plateNumber.isEmpty) return 'Обязательное поле';
        if (!_isValidPlateNumber(plateNumber)) return 'Только латиница и цифры (A123BC777)';
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
      case 'length':
      case 'height':
      case 'width':
      case 'capacity':
        final value = fieldName == 'length' ? length :
                      fieldName == 'height' ? height :
                      fieldName == 'width' ? width : capacity;
        if (value.isEmpty) return 'Обязательное поле';
        if (!_isValidNumber(value)) return 'Только цифры';
        return null;
      default:
        if (!isFieldValid(fieldName)) return 'Обязательное поле';
        return null;
    }
  }

  // Валидация обязательных полей
  bool get isStep1Valid {
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

  bool get isStep2Valid {
    if (isTruck) {
      return length.isNotEmpty &&
             height.isNotEmpty &&
             width.isNotEmpty &&
             capacity.isNotEmpty;
    }
    return true;
  }

  // Преобразование в формат Yandex API
  Map<String, dynamic> toYandexApiJson() {
    final Map<String, dynamic> payload = {
      'park_profile': {
        'status': 'working',
        'fuel_type': _mapFuelType(fuelType),
        'is_park_property': isParkVehicle,
        'ownership_type': 'park', // Тип собственности: park или leasing
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

    // Добавляем опциональные поля
    if (callsign.isNotEmpty) {
      payload['park_profile']['callsign'] = callsign;
    }

    if (bodyNumber.isNotEmpty) {
      payload['vehicle_specifications']['body_number'] = bodyNumber;
    }

    // Добавляем amenities если есть кондиционер
    if (hasAirConditioner) {
      payload['park_profile']['amenities'] = ['conditioner'];
    }

    // Добавляем параметры грузового отсека для грузовых автомобилей
    if (isTruck && length.isNotEmpty && height.isNotEmpty && width.isNotEmpty && capacity.isNotEmpty) {
      payload['cargo'] = {
        'cargo_hold_dimensions': {
          'length': int.tryParse(length) ?? 0,
          'height': int.tryParse(height) ?? 0,
          'width': int.tryParse(width) ?? 0,
        },
        'carrying_capacity': int.tryParse(capacity) ?? 0,
      };
    }

    return payload;
  }

  String _mapFuelType(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case 'бензин': return 'petrol';
      case 'метан': return 'methane';
      case 'пропан': return 'propane';
      case 'электричество': return 'electricity';
      default: return 'petrol';
    }
  }

  String _mapColor(String color) {
    switch (color) {
      case 'Белый': return 'Белый';
      case 'Желтый': return 'Желтый';
      case 'Бежевый': return 'Бежевый';
      case 'Черный': return 'Черный';
      case 'Голубой': return 'Голубой';
      case 'Серый': return 'Серый';
      case 'Красный': return 'Красный';
      case 'Оранжевый': return 'Оранжевый';
      case 'Синий': return 'Синий';
      case 'Зеленый': return 'Зеленый';
      case 'Коричневый': return 'Коричневый';
      case 'Фиолетовый': return 'Фиолетовый';
      case 'Розовый': return 'Розовый';
      default: return color;
    }
  }

  String _mapTransmission(String transmission) {
    switch (transmission.toLowerCase()) {
      case 'механическая': return 'mechanical';
      case 'автоматическая': return 'automatic';
      case 'роботизированная': return 'robotic';
      case 'вариатор': return 'variator';
      default: return 'mechanical';
    }
  }

  // Транслитерация номера автомобиля (кириллица → латиница)
  String _transliteratePlateNumber(String text) {
    const Map<String, String> translitMap = {
      'А': 'A', 'а': 'A',
      'В': 'B', 'в': 'B',
      'Е': 'E', 'е': 'E',
      'К': 'K', 'к': 'K',
      'М': 'M', 'м': 'M',
      'Н': 'H', 'н': 'H',
      'О': 'O', 'о': 'O',
      'Р': 'P', 'р': 'P',
      'С': 'C', 'с': 'C',
      'Т': 'T', 'т': 'T',
      'У': 'Y', 'у': 'Y',
      'Х': 'X', 'х': 'X',
    };
    
    return text.split('').map((char) => translitMap[char] ?? char).join('').toUpperCase();
  }

  // Транслитерация для СТС и других полей
  String _transliterateToLatin(String text) {
    const Map<String, String> translitMap = {
      'А': 'A', 'а': 'a',
      'Б': 'B', 'б': 'b',
      'В': 'V', 'в': 'v',
      'Г': 'G', 'г': 'g',
      'Д': 'D', 'д': 'd',
      'Е': 'E', 'е': 'e',
      'Ё': 'E', 'ё': 'e',
      'Ж': 'Zh', 'ж': 'zh',
      'З': 'Z', 'з': 'z',
      'И': 'I', 'и': 'i',
      'Й': 'Y', 'й': 'y',
      'К': 'K', 'к': 'k',
      'Л': 'L', 'л': 'l',
      'М': 'M', 'м': 'm',
      'Н': 'N', 'н': 'n',
      'О': 'O', 'о': 'o',
      'П': 'P', 'п': 'p',
      'Р': 'R', 'р': 'r',
      'С': 'S', 'с': 's',
      'Т': 'T', 'т': 't',
      'У': 'U', 'у': 'u',
      'Ф': 'F', 'ф': 'f',
      'Х': 'Kh', 'х': 'kh',
      'Ц': 'Ts', 'ц': 'ts',
      'Ч': 'Ch', 'ч': 'ch',
      'Ш': 'Sh', 'ш': 'sh',
      'Щ': 'Shch', 'щ': 'shch',
      'Ъ': '', 'ъ': '',
      'Ы': 'Y', 'ы': 'y',
      'Ь': '', 'ь': '',
      'Э': 'E', 'э': 'e',
      'Ю': 'Yu', 'ю': 'yu',
      'Я': 'Ya', 'я': 'ya',
    };
    
    return text.split('').map((char) => translitMap[char] ?? char).join();
  }
}

class AddVehicleFormNotifier extends Notifier<AddVehicleFormData> {
  @override
  AddVehicleFormData build() {
    // Начальное состояние формы
    return const AddVehicleFormData();
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
    String? length,
    String? height,
    String? width,
    String? capacity,
    String? callsign,
  }) {
    state = state.copyWith(
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
      length: length,
      height: height,
      width: width,
      capacity: capacity,
      callsign: callsign,
    );
  }

  void setStep(int step) {
    // При переходе на шаг 2 включаем показ ошибок если есть невалидные поля
    if (step == 2 && !state.isStep1Valid) {
      state = state.copyWith(showValidationErrors: true);
      return;
    }
    state = state.copyWith(step: step, showValidationErrors: false);
  }

  void setIsTruck(bool isTruck) => state = state.copyWith(isTruck: isTruck);
  void setIsParkVehicle(bool isParkVehicle) =>
      state = state.copyWith(isParkVehicle: isParkVehicle);
  void setHasAirConditioner(bool hasAirConditioner) =>
      state = state.copyWith(hasAirConditioner: hasAirConditioner);

  void reset() {
    state = const AddVehicleFormData();
  }

  Future<String?> submit() async {
    // Включаем показ ошибок
    state = state.copyWith(showValidationErrors: true);
    
    // Валидация
    if (!state.isStep1Valid) {
      return 'Заполните все обязательные поля';
    }
    
    if (!state.isStep2Valid) {
      return 'Заполните все обязательные поля для грузового автомобиля';
    }

    try {
      final dio = ref.read(dioProvider);
      final secureStorage = ref.read(secureStorageServiceProvider);
      final vehiclesService = VehiclesService(dio, secureStorage);
      
      final payload = state.toYandexApiJson();
      await vehiclesService.createVehicle(payload);
      
      reset();
      return null; // успех
    } catch (e) {
      // Извлекаем чистое сообщение об ошибке
      final errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        return errorMessage.substring('Exception: '.length);
      }
      return errorMessage;
    }
  }
}

// Провайдер, завязанный на жизненный цикл. KeepAlive можно использовать, если нужно
// сохранять состояние после закрытия. Сейчас используем NotifierProvider.
// AutoDispose означает, что форма сбросится, если ее закрыть (никто не слушает).
// Уберем autoDispose, если хотим чтобы при закрытии и открытии шторки данные оставались.
final addVehicleFormProvider =
    NotifierProvider<AddVehicleFormNotifier, AddVehicleFormData>(
      () => AddVehicleFormNotifier(),
    );
