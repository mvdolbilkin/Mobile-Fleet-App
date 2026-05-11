class VehicleTypesResponse {
  final List<VehicleType> vehicleTypes;

  const VehicleTypesResponse({required this.vehicleTypes});

  factory VehicleTypesResponse.fromJson(Map<String, dynamic> json) {
    return VehicleTypesResponse(
      vehicleTypes: (json['vehicle_types'] as List? ?? [])
          .map((e) => VehicleType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VehicleType {
  final String value;
  final String label;

  const VehicleType({required this.value, required this.label});

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}
