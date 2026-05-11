class CarStatus {
  final String id;
  final String name;

  const CarStatus({required this.id, required this.name});

  factory CarStatus.fromJson(Map<String, dynamic> json) {
    return CarStatus(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
