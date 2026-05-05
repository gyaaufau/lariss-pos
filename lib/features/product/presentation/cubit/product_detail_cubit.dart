import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/category_domain/domain/entities/category_entity.dart';
import '../../../../domain/category_domain/domain/usecases/get_categories.dart';
import '../../../../domain/product_domain/domain/entities/product_entity.dart';
import '../../../../domain/product_domain/domain/usecases/delete_product.dart';
import '../../../../domain/product_domain/domain/usecases/get_product_by_id.dart';

enum ProductDetailStatus { initial, loading, success, failure, deleting }

class ProductDetailState {
  const ProductDetailState({
    this.status = ProductDetailStatus.initial,
    this.product,
    this.categories = const <CategoryEntity>[],
    this.errorMessage,
  });

  final ProductDetailStatus status;
  final ProductEntity? product;
  final List<CategoryEntity> categories;
  final String? errorMessage;

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    ProductEntity? product,
    List<CategoryEntity>? categories,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product ?? this.product,
      categories: categories ?? this.categories,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({
    required GetProductById getProductById,
    required GetCategories getCategories,
    required DeleteProduct deleteProduct,
  }) : _getProductById = getProductById,
       _getCategories = getCategories,
       _deleteProduct = deleteProduct,
       super(const ProductDetailState());

  final GetProductById _getProductById;
  final GetCategories _getCategories;
  final DeleteProduct _deleteProduct;

  Future<void> loadProduct(String id) async {
    emit(
      state.copyWith(
        status: ProductDetailStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final categoriesResult = await _getCategories();
    final productResult = await _getProductById(id);

    categoriesResult.match(
      (failure) => emit(
        state.copyWith(
          status: ProductDetailStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (categories) => productResult.match(
        (failure) => emit(
          state.copyWith(
            status: ProductDetailStatus.failure,
            categories: categories,
            errorMessage: failure.message,
          ),
        ),
        (product) => emit(
          state.copyWith(
            status: ProductDetailStatus.success,
            product: product,
            categories: categories,
            clearErrorMessage: true,
          ),
        ),
      ),
    );
  }

  Future<bool> deleteCurrentProduct() async {
    final product = state.product;
    if (product == null) {
      emit(
        state.copyWith(
          status: ProductDetailStatus.failure,
          errorMessage: 'Produk tidak ditemukan.',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        status: ProductDetailStatus.deleting,
        clearErrorMessage: true,
      ),
    );

    final result = await _deleteProduct(product.id);
    return result.match((failure) {
      emit(
        state.copyWith(
          status: ProductDetailStatus.failure,
          errorMessage: failure.message,
        ),
      );
      return false;
    }, (_) => true);
  }
}
