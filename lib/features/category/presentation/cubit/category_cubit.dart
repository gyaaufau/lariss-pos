import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/category_domain/domain/usecases/create_category.dart';
import '../../../../domain/category_domain/domain/usecases/get_categories.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit({
    required GetCategories getCategories,
    required CreateCategory createCategory,
  }) : _getCategories = getCategories,
       _createCategory = createCategory,
       super(const CategoryState());

  final GetCategories _getCategories;
  final CreateCategory _createCategory;

  Future<void> loadCategories() async {
    emit(
      state.copyWith(status: CategoryStatus.loading, clearErrorMessage: true),
    );

    final result = await _getCategories();

    result.match(
      (failure) => emit(
        state.copyWith(
          status: CategoryStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (categories) => emit(
        state.copyWith(
          status: CategoryStatus.success,
          categories: categories,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<bool> createCategory(String name) async {
    emit(
      state.copyWith(
        status: CategoryStatus.submitting,
        clearErrorMessage: true,
      ),
    );

    final result = await _createCategory(name);

    return result.match(
      (failure) {
        emit(
          state.copyWith(
            status: CategoryStatus.failure,
            errorMessage: failure.message,
          ),
        );

        return false;
      },
      (_) async {
        await loadCategories();
        return true;
      },
    );
  }
}
