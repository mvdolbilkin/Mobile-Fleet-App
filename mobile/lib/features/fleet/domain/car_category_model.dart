class CarCategory {
  final String id;
  final String name;

  const CarCategory({required this.id, required this.name});

  factory CarCategory.fromJson(Map<String, dynamic> json) {
    return CarCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
