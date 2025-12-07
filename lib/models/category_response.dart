// models/category_response.dart
import 'package:injera/models/category_model.dart';

class CategoryResponse {
  final List<Category> categories;
  final String? error;

  CategoryResponse({required this.categories, this.error});

  factory CategoryResponse.fromJson(List<dynamic> json) {
    final categories = json.map((item) => Category.fromJson(item)).toList();

    return CategoryResponse(categories: categories);
  }
}
