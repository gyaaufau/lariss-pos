import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/category_domain/domain/entities/category_entity.dart';
import '../../../../domain/category_domain/domain/usecases/delete_category.dart';
import '../../../../domain/category_domain/domain/usecases/get_category_by_id.dart';

enum CategoryDetailStatus { initial, loading, success, failure, deleting }

class CategoryDetailState {
  const CategoryDetailState({
    this.status = CategoryDetailStatus.initial,
    this.category,
    this.errorMessage,
  });

  final CategoryDetailStatus status;
  final CategoryEntity? category;
  final String? errorMessage;

  CategoryDetailState copyWith({
    CategoryDetailStatus? status,
    CategoryEntity? category,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CategoryDetailState(
      status: status ?? this.status,
      category: category ?? this.category,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class CategoryDetailCubit extends Cubit<CategoryDetailState> {
  CategoryDetailCubit({
    required GetCategoryById getCategoryById,
    required DeleteCategory deleteCategory,
  }) : _getCategoryById = getCategoryById,
       _deleteCategory = deleteCategory,
       super(const CategoryDetailState());

  final GetCategoryById _getCategoryById;
  final DeleteCategory _deleteCategory;

  Future<void> loadCategory(String id) async {
    emit(
      state.copyWith(
        status: CategoryDetailStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final result = await _getCategoryById(id);
    result.match(
      (failure) => emit(
        state.copyWith(
          status: CategoryDetailStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (category) => emit(
        state.copyWith(
          status: CategoryDetailStatus.success,
          category: category,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<bool> deleteCurrentCategory() async {
    final category = state.category;
    if (category == null) {
      emit(
        state.copyWith(
          status: CategoryDetailStatus.failure,
          errorMessage: 'Kategori tidak ditemukan.',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        status: CategoryDetailStatus.deleting,
        clearErrorMessage: true,
      ),
    );

    final result = await _deleteCategory(category.id);
    return result.match((failure) {
      emit(
        state.copyWith(
          status: CategoryDetailStatus.failure,
          errorMessage: failure.message,
        ),
      );
      return false;
    }, (_) => true);
  }
}
