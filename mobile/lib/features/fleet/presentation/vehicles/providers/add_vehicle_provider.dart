import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    );
  }

  // Здесь в будущем будет метод toJson() для отправки на сервер
  Map<String, dynamic> toJson() {
    return {
      'type': isTruck ? 'truck' : 'car',
      'sts': sts,
      'plate_number': plateNumber,
      'brand': brand,
      'year': year,
      'sts_issue_date': stsIssueDate,
      'vin': vin,
      'model': model,
      'body_number': bodyNumber,
      'color': color,
      'fuel_type': fuelType,
      'transmission': transmission,
      'length': length,
      'height': height,
      'width': width,
      'capacity': capacity,
      'is_park_vehicle': isParkVehicle,
      'has_air_conditioner': hasAirConditioner,
      'callsign': callsign,
    };
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

  void setStep(int step) => state = state.copyWith(step: step);
  void setIsTruck(bool isTruck) => state = state.copyWith(isTruck: isTruck);
  void setIsParkVehicle(bool isParkVehicle) =>
      state = state.copyWith(isParkVehicle: isParkVehicle);
  void setHasAirConditioner(bool hasAirConditioner) =>
      state = state.copyWith(hasAirConditioner: hasAirConditioner);

  void reset() {
    state = const AddVehicleFormData();
  }

  Future<void> submit() async {
    // В будущем здесь будет логика отправки на сервер
    // final payload = state.toJson();
    // await _repository.createVehicle(payload);

    // Эмуляция задержки сети
    await Future.delayed(const Duration(milliseconds: 500));
    reset(); // очищаем форму после успешной отправки
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
