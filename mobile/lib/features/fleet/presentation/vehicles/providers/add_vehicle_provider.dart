import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/data/vehicles_service.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'vehicles_provider.dart';

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
  final String parkingAddress;

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
    this.parkingAddress = '',
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
    String? parkingAddress,
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
      parkingAddress: parkingAddress ?? this.parkingAddress,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
    );
  }

  // Проверка конкретных полей
  bool isFieldValid(String fieldName) {
    switch (fieldName) {
      case 'sts':
        return sts.isNotEmpty && _isValidLatinOrDigits(sts);
      case 'plateNumber':
        return plateNumber.isNotEmpty && _isValidPlateNumber(plateNumber);
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
      case 'length':
        return length.isNotEmpty && _isValidLength(length);
      case 'height':
        return height.isNotEmpty && _isValidHeight(height);
      case 'width':
        return width.isNotEmpty && _isValidWidth(width);
      case 'capacity':
        return capacity.isNotEmpty && _isValidCapacity(capacity);
      default:
        return true;
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

  // Валидация длины грузового отсека (170-601 см)
  bool _isValidLength(String value) {
    final num = int.tryParse(value);
    if (num == null) return false;
    return num >= 170 && num <= 601;
  }

  // Валидация ширины грузового отсека (96-250 см)
  bool _isValidWidth(String value) {
    final num = int.tryParse(value);
    if (num == null) return false;
    return num >= 96 && num <= 250;
  }

  // Валидация высоты грузового отсека (90-250 см)
  bool _isValidHeight(String value) {
    final num = int.tryParse(value);
    if (num == null) return false;
    return num >= 90 && num <= 250;
  }

  // Валидация грузоподъемности (300-6000 кг)
  bool _isValidCapacity(String value) {
    final num = int.tryParse(value);
    if (num == null) return false;
    return num >= 300 && num <= 6000;
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
        if (!_isValidPlateNumber(plateNumber))
          return 'Только латиница и цифры (A123BC777)';
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
        if (length.isEmpty) return 'Обязательное поле';
        if (!_isValidNumber(length)) return 'Только цифры';
        if (!_isValidLength(length)) return 'Длина от 170 до 601 см';
        return null;
      case 'height':
        if (height.isEmpty) return 'Обязательное поле';
        if (!_isValidNumber(height)) return 'Только цифры';
        if (!_isValidHeight(height)) return 'Высота от 90 до 250 см';
        return null;
      case 'width':
        if (width.isEmpty) return 'Обязательное поле';
        if (!_isValidNumber(width)) return 'Только цифры';
        if (!_isValidWidth(width)) return 'Ширина от 96 до 250 см';
        return null;
      case 'capacity':
        if (capacity.isEmpty) return 'Обязательное поле';
        if (!_isValidNumber(capacity)) return 'Только цифры';
        if (!_isValidCapacity(capacity))
          return 'Грузоподъемность от 300 до 6000 кг';
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
        _isValidVIN(vin) &&
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

  // Преобразование в формат Yandex API (vehicles-manager/v1/vehicles)
  Map<String, dynamic> toYandexApiJson() {
    final List<String> amenities = [];
    if (hasAirConditioner) {
      amenities.add('conditioner');
    }

    final Map<String, dynamic> payload = {
      'vehicle_specifications': {
        'brand': brand,
        'model': model,
        'color': _mapColor(color),
        'year': int.tryParse(year) ?? 0,
        'transmission': _mapTransmission(transmission),
        'vin': vin.toUpperCase(),
      },
      'vehicle_licenses': {
        'licence_plate_number': _transliteratePlateNumber(plateNumber),
        'registration_certificate': _transliterateToLatin(sts),
        'registration_cert_issue_date': stsIssueDate.isNotEmpty
            ? _formatDateForApi(stsIssueDate)
            : '',
      },
      'park_profile': {
        'status': 'working',
        'amenities': amenities,
        'fuel_type': _mapFuelType(fuelType),
        'is_park_property': isParkVehicle,
        'categories': isTruck
            ? ['cargo']
            : [
                'express',
                'econom',
                'comfort',
                'comfort_plus',
                'minivan',
                'intercity',
                'business',
                'ultimate',
                'premium_van',
                'personal_driver',
                'vip',
                'suv',
                'premium_suv',
                'envoy_ultima',
                'maybach',
                'standart',
                'summit_b2b',
                'transfer',
                'wagon',
              ],
      },
    };

    // Добавляем опциональные поля
    if (callsign.isNotEmpty) {
      payload['park_profile']['callsign'] = callsign;
    }

    if (bodyNumber.isNotEmpty) {
      payload['vehicle_specifications']['body_number'] = bodyNumber;
    }

    if (parkingAddress.isNotEmpty) {
      payload['park_profile']['office_id'] = parkingAddress;
    }

    // Добавляем параметры грузового отсека для грузовых автомобилей
    if (isTruck &&
        length.isNotEmpty &&
        height.isNotEmpty &&
        width.isNotEmpty &&
        capacity.isNotEmpty) {
      payload['cargo'] = {
        'cargo_loaders': 0,
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

  // Конвертирует дату из DD.MM.YYYY в YYYY-MM-DD для API
  String _formatDateForApi(String dateStr) {
    try {
      final parts = dateStr.split('.');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
    } catch (e) {}
    return dateStr;
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
    switch (color) {
      case 'Белый':
        return 'Белый';
      case 'Желтый':
        return 'Желтый';
      case 'Бежевый':
        return 'Бежевый';
      case 'Черный':
        return 'Черный';
      case 'Голубой':
        return 'Голубой';
      case 'Серый':
        return 'Серый';
      case 'Красный':
        return 'Красный';
      case 'Оранжевый':
        return 'Оранжевый';
      case 'Синий':
        return 'Синий';
      case 'Зеленый':
        return 'Зеленый';
      case 'Коричневый':
        return 'Коричневый';
      case 'Фиолетовый':
        return 'Фиолетовый';
      case 'Розовый':
        return 'Розовый';
      default:
        return color;
    }
  }

  String _mapTransmission(String transmission) {
    const validIds = ['unknown', 'mechanical', 'automatic', 'robotic', 'variator'];
    if (validIds.contains(transmission)) return transmission;

    switch (transmission.toLowerCase()) {
      case 'механическая':
      case 'механика':
        return 'mechanical';
      case 'автоматическая':
      case 'автомат':
        return 'automatic';
      case 'роботизированная':
      case 'робот':
        return 'robotic';
      case 'вариатор':
        return 'variator';
      default:
        return 'mechanical';
    }
  }

  // Транслитерация номера автомобиля (кириллица → латиница)
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
        .join('')
        .toUpperCase();
  }

  // Транслитерация для СТС и других полей
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
    String? parkingAddress,
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
      parkingAddress: parkingAddress,
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

  void showValidationErrors() {
    state = state.copyWith(showValidationErrors: true);
  }

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

      // Инвалидируем кэш списка
      ref.invalidate(vehiclesProvider);

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

// ─── Справочники (references) ────────────────────────────────────────────

class ReferenceItem {
  final String id;
  final String name;
  const ReferenceItem({required this.id, required this.name});
}

class VehicleReferences {
  final List<ReferenceItem> transmissions;
  final List<ReferenceItem> categories;
  final List<ReferenceItem> colors;
  final List<String> years;

  const VehicleReferences({
    this.transmissions = const [],
    this.categories = const [],
    this.colors = const [],
    this.years = const [],
  });

  factory VehicleReferences.fromJson(Map<String, dynamic> json) {
    List<ReferenceItem> parseItems(String key) {
      final list = json[key] as List<dynamic>? ?? [];
      return list
          .map((e) => ReferenceItem(
                id: (e as Map<String, dynamic>)['id']?.toString() ?? '',
                name: (e['name'] as String?) ?? '',
              ))
          .where((item) => item.id.isNotEmpty)
          .toList();
    }

    final yearsList = (json['car_years'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return VehicleReferences(
      transmissions: parseItems('car_transmissions'),
      categories: parseItems('car_categories'),
      colors: parseItems('colors'),
      years: yearsList,
    );
  }

  String? transmissionName(String id) {
    for (final t in transmissions) {
      if (t.id == id) return t.name;
    }
    return null;
  }

  String? transmissionId(String name) {
    for (final t in transmissions) {
      if (t.name == name) return t.id;
    }
    return null;
  }

  String? colorName(String id) {
    for (final c in colors) {
      if (c.id == id) return c.name;
    }
    return null;
  }

  String? colorId(String name) {
    for (final c in colors) {
      if (c.name == name) return c.id;
    }
    return null;
  }
}

final vehicleReferencesProvider = FutureProvider<VehicleReferences>((ref) async {
  final dio = ref.read(dioProvider);
  final secureStorage = ref.read(secureStorageServiceProvider);
  final service = VehiclesService(dio, secureStorage);
  final json = await service.getReferences();
  return VehicleReferences.fromJson(json);
});

// Провайдер для загрузки списка марок
final brandsProvider = FutureProvider<List<String>>((ref) async {
  final dio = ref.read(dioProvider);
  final secureStorage = ref.read(secureStorageServiceProvider);
  final service = VehiclesService(dio, secureStorage);
  return service.getBrands();
});

// Провайдер для загрузки моделей по выбранной марке
final modelsProvider = FutureProvider.family<List<String>, String>((
  ref,
  brand,
) async {
  if (brand.isEmpty) return [];
  final dio = ref.read(dioProvider);
  final secureStorage = ref.read(secureStorageServiceProvider);
  final service = VehiclesService(dio, secureStorage);
  return service.getModels(brand);
});
