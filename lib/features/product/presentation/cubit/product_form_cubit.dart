import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/category_domain/domain/entities/category_entity.dart';
import '../../../../domain/category_domain/domain/usecases/get_categories.dart';
import '../../../../domain/product_domain/domain/entities/product_entity.dart';
import '../../../../domain/product_domain/domain/usecases/create_product.dart';
import '../../../../domain/product_domain/domain/usecases/get_product_by_id.dart';
import '../../../../domain/product_domain/domain/usecases/update_product.dart';

enum ProductFormStatus { initial, loading, ready, submitting, failure }

class ProductFormState {
  const ProductFormState({
    this.status = ProductFormStatus.initial,
    this.categories = const <CategoryEntity>[],
    this.product,
    this.errorMessage,
  });

  final ProductFormStatus status;
  final List<CategoryEntity> categories;
  final ProductEntity? product;
  final String? errorMessage;

  bool get isEditing => product != null;

  ProductFormState copyWith({
    ProductFormStatus? status,
    List<CategoryEntity>? categories,
    ProductEntity? product,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProductFormState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      product: product ?? this.product,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class ProductFormCubit extends Cubit<ProductFormState> {
  ProductFormCubit({
    required GetCategories getCategories,
    required GetProductById getProductById,
    required CreateProduct createProduct,
    required UpdateProduct updateProduct,
  }) : _getCategories = getCategories,
       _getProductById = getProductById,
       _createProduct = createProduct,
       _updateProduct = updateProduct,
       super(const ProductFormState());

  final GetCategories _getCategories;
  final GetProductById _getProductById;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;

  Future<void> initialize({String? productId}) async {
    emit(
      state.copyWith(
        status: ProductFormStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final categoriesResult = await _getCategories();

    await categoriesResult.match(
      (failure) async {
        emit(
          state.copyWith(
            status: ProductFormStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (categories) async {
        if (productId == null) {
          emit(
            state.copyWith(
              status: ProductFormStatus.ready,
              categories: categories,
              clearErrorMessage: true,
            ),
          );
          return;
        }

        final productResult = await _getProductById(productId);
        productResult.match(
          (failure) => emit(
            state.copyWith(
              status: ProductFormStatus.failure,
              categories: categories,
              errorMessage: failure.message,
            ),
          ),
          (product) => emit(
            state.copyWith(
              status: ProductFormStatus.ready,
              categories: categories,
              product: product,
              clearErrorMessage: true,
            ),
          ),
        );
      },
    );
  }

  Future<bool> submit({
    required String categoryId,
    required String name,
    required int sellingPrice,
    required int currentStock,
    required int minimumStock,
    required bool isActive,
  }) async {
    emit(
      state.copyWith(
        status: ProductFormStatus.submitting,
        clearErrorMessage: true,
      ),
    );

    final product = state.product;
    final result = product == null
        ? await _createProduct(
            CreateProductParams(
              categoryId: categoryId,
              name: name,
              sellingPrice: sellingPrice,
              currentStock: currentStock,
              minimumStock: minimumStock,
              isActive: isActive,
            ),
          )
        : await _updateProduct(
            UpdateProductParams(
              id: product.id,
              categoryId: categoryId,
              name: name,
              sellingPrice: sellingPrice,
              currentStock: currentStock,
              minimumStock: minimumStock,
              isActive: isActive,
              createdAt: product.createdAt,
            ),
          );

    return result.match(
      (failure) {
        emit(
          state.copyWith(
            status: ProductFormStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return false;
      },
      (savedProduct) {
        emit(
          state.copyWith(
            status: ProductFormStatus.ready,
            product: savedProduct,
            clearErrorMessage: true,
          ),
        );
        return true;
      },
    );
  }
}
