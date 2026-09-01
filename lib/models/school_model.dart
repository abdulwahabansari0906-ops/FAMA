class SchoolModel {
  final int id;
  final String name;

  SchoolModel({required this.id, required this.name});

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}