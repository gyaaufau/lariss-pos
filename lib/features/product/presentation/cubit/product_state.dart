import '../../../../domain/category_domain/domain/entities/category_entity.dart';
import '../../../../domain/product_domain/domain/entities/product_entity.dart';

enum ProductStatus { initial, loading, success, failure, submitting, deleting }

class ProductState {
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const <ProductEntity>[],
    this.categories = const <CategoryEntity>[],
    this.errorMessage,
  });

  final ProductStatus status;
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final String? errorMessage;

  ProductState copyWith({
    ProductStatus? status,
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
