import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/category_domain/domain/entities/category_entity.dart';
import '../../../../domain/category_domain/domain/usecases/create_category.dart';
import '../../../../domain/category_domain/domain/usecases/get_category_by_id.dart';
import '../../../../domain/category_domain/domain/usecases/update_category.dart';

enum CategoryFormStatus { initial, loading, ready, submitting, failure }

class CategoryFormState {
  const CategoryFormState({
    this.status = CategoryFormStatus.initial,
    this.category,
    this.errorMessage,
  });

  final CategoryFormStatus status;
  final CategoryEntity? category;
  final String? errorMessage;

  bool get isEditing => category != null;

  CategoryFormState copyWith({
    CategoryFormStatus? status,
    CategoryEntity? category,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CategoryFormState(
      status: status ?? this.status,
      category: category ?? this.category,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class CategoryFormCubit extends Cubit<CategoryFormState> {
  CategoryFormCubit({
    required CreateCategory createCategory,
    required GetCategoryById getCategoryById,
    required UpdateCategory updateCategory,
  }) : _createCategory = createCategory,
       _getCategoryById = getCategoryById,
       _updateCategory = updateCategory,
       super(const CategoryFormState());

  final CreateCategory _createCategory;
  final GetCategoryById _getCategoryById;
  final UpdateCategory _updateCategory;

  Future<void> initialize({String? categoryId}) async {
    if (categoryId == null) {
      emit(
        state.copyWith(
          status: CategoryFormStatus.ready,
          clearErrorMessage: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: CategoryFormStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final result = await _getCategoryById(categoryId);
    result.match(
      (failure) => emit(
        state.copyWith(
          status: CategoryFormStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (category) => emit(
        state.copyWith(
          status: CategoryFormStatus.ready,
          category: category,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<bool> submit(String name) async {
    emit(
      state.copyWith(
        status: CategoryFormStatus.submitting,
        clearErrorMessage: true,
      ),
    );

    final category = state.category;
    final result = category == null
        ? await _createCategory(name)
        : await _updateCategory(
            UpdateCategoryParams(
              id: category.id,
              name: name,
              createdAt: category.createdAt,
            ),
          );

    return result.match(
      (failure) {
        emit(
          state.copyWith(
            status: CategoryFormStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return false;
      },
      (savedCategory) {
        emit(
          state.copyWith(
            status: CategoryFormStatus.ready,
            category: savedCategory,
            clearErrorMessage: true,
          ),
        );
        return true;
      },
    );
  }
}
