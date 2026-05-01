import '../../../../domain/category_domain/domain/entities/category_entity.dart';

enum CategoryStatus { initial, loading, success, failure, submitting }

class CategoryState {
  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const <CategoryEntity>[],
    this.errorMessage,
  });

  final CategoryStatus status;
  final List<CategoryEntity> categories;
  final String? errorMessage;

  CategoryState copyWith({
    CategoryStatus? status,
    List<CategoryEntity>? categories,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
