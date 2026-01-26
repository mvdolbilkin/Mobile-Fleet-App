class Vehicle {
  final String id;
  final String plateNumber;
  final String model;
  final String year;
  final String color;
  final VehicleStatus status;
  final int mileage;
  final String? driverName;
  final String? imageUrl;

  Vehicle({
    required this.id,
    required this.plateNumber,
    required this.model,
    required this.year,
    required this.color,
    required this.status,
    required this.mileage,
    this.driverName,
    this.imageUrl,
  });
}

enum VehicleStatus {
  working,
  service,
  noDriver,
  preparation,
}

// Моковые данные
final List<Vehicle> mockVehicles = [
  Vehicle(
    id: '1',
    plateNumber: 'A777AA',
    model: 'AC Ace 2020 Бежевый',
    year: '2020',
    color: 'Бежевый',
    status: VehicleStatus.working,
    mileage: 222222,
    driverName: '1234567890',
  ),
  Vehicle(
    id: '2',
    plateNumber: 'B735OC763',
    model: 'Mahindra (tricycle) Alfa',
    year: '2019',
    color: 'Красный',
    status: VehicleStatus.service,
    mileage: 234214,
    driverName: '111111111111112',
  ),
  Vehicle(
    id: '3',
    plateNumber: 'XP21277',
    model: 'Acura CL 2017 Белый',
    year: '2017',
    color: 'Белый',
    status: VehicleStatus.noDriver,
    mileage: 1234,
    driverName: 'внпп',
  ),
  Vehicle(
    id: '4',
    plateNumber: 'XP36379',
    model: 'Mercedes-Benz E-klasse',
    year: '2021',
    color: 'Черный',
    status: VehicleStatus.preparation,
    mileage: 15000,
  ),
];
