import 'package:flutter_riverpod/legacy.dart';
import '../services/category_service.dart';
import '../models/category_model.dart';

class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;
  final Category? selectedCategory;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
    Category? selectedCategory,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryService _service = CategoryService();

  CategoryNotifier() : super(const CategoryState());

  Future<void> fetchCategories() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final categories = await _service.fetchCategories();
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void selectCategory(String categoryId) {
    final category = state.categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => state.categories.firstOrNull ?? Category(id: '', name: ''),
    );
    state = state.copyWith(selectedCategory: category);
  }

  void clearSelection() {
    state = state.copyWith(selectedCategory: null);
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>(
  (ref) => CategoryNotifier(),
);
