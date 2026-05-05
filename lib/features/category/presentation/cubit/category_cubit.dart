import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/category_domain/domain/usecases/get_categories.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit({required GetCategories getCategories})
    : _getCategories = getCategories,
      super(const CategoryState());

  final GetCategories _getCategories;

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
}
