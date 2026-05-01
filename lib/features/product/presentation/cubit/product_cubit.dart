import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/category_domain/domain/usecases/get_categories.dart';
import '../../../../domain/product_domain/domain/entities/product_entity.dart';
import '../../../../domain/product_domain/domain/usecases/create_product.dart';
import '../../../../domain/product_domain/domain/usecases/delete_product.dart';
import '../../../../domain/product_domain/domain/usecases/get_products.dart';
import '../../../../domain/product_domain/domain/usecases/update_product.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit({
    required GetProducts getProducts,
    required CreateProduct createProduct,
    required UpdateProduct updateProduct,
    required DeleteProduct deleteProduct,
    required GetCategories getCategories,
  }) : _getProducts = getProducts,
       _createProduct = createProduct,
       _updateProduct = updateProduct,
       _deleteProduct = deleteProduct,
       _getCategories = getCategories,
       super(const ProductState());

  final GetProducts _getProducts;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final GetCategories _getCategories;

  Future<void> loadProducts() async {
    emit(
      state.copyWith(status: ProductStatus.loading, clearErrorMessage: true),
    );

    final categoriesResult = await _getCategories();
    final productsResult = await _getProducts();

    categoriesResult.match(
      (failure) => emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (categories) => productsResult.match(
        (failure) => emit(
          state.copyWith(
            status: ProductStatus.failure,
            errorMessage: failure.message,
            categories: categories,
          ),
        ),
        (products) => emit(
          state.copyWith(
            status: ProductStatus.success,
            products: products,
            categories: categories,
            clearErrorMessage: true,
          ),
        ),
      ),
    );
  }

  Future<bool> createProduct(CreateProductParams params) async {
    emit(
      state.copyWith(status: ProductStatus.submitting, clearErrorMessage: true),
    );

    final result = await _createProduct(params);

    return result.match(
      (failure) {
        emit(
          state.copyWith(
            status: ProductStatus.failure,
            errorMessage: failure.message,
          ),
        );

        return false;
      },
      (_) async {
        await loadProducts();
        return true;
      },
    );
  }

  Future<bool> updateProduct(UpdateProductParams params) async {
    emit(
      state.copyWith(status: ProductStatus.submitting, clearErrorMessage: true),
    );

    final result = await _updateProduct(params);

    return result.match(
      (failure) {
        emit(
          state.copyWith(
            status: ProductStatus.failure,
            errorMessage: failure.message,
          ),
        );

        return false;
      },
      (_) async {
        await loadProducts();
        return true;
      },
    );
  }

  Future<bool> deleteProduct(ProductEntity product) async {
    emit(
      state.copyWith(status: ProductStatus.deleting, clearErrorMessage: true),
    );

    final result = await _deleteProduct(product.id);

    return result.match(
      (failure) {
        emit(
          state.copyWith(
            status: ProductStatus.failure,
            errorMessage: failure.message,
          ),
        );

        return false;
      },
      (_) async {
        await loadProducts();
        return true;
      },
    );
  }
}
