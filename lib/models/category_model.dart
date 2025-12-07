// models/category_model.dart
class Category {
  final String id;
  final String name;

  const Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
