import '../models/product_model.dart';

abstract class ProductLocalDatasource {
  Future<List<ProductModel>> getProducts();

  Future<ProductModel> createProduct({
    required String categoryId,
    required String name,
    required int sellingPrice,
    required int currentStock,
    required int minimumStock,
    required bool isActive,
  });

  Future<ProductModel> updateProduct({
    required String id,
    required String categoryId,
    required String name,
    required int sellingPrice,
    required int currentStock,
    required int minimumStock,
    required bool isActive,
    required int createdAt,
  });

  Future<void> deleteProduct(String id);
}
