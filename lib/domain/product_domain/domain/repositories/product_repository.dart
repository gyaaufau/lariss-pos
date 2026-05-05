import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();

  Future<Either<Failure, ProductEntity>> getProductById(String id);

  Future<Either<Failure, ProductEntity>> createProduct({
    required String categoryId,
    required String name,
    required int sellingPrice,
    required int currentStock,
    required int minimumStock,
    required bool isActive,
  });

  Future<Either<Failure, ProductEntity>> updateProduct({
    required String id,
    required String categoryId,
    required String name,
    required int sellingPrice,
    required int currentStock,
    required int minimumStock,
    required bool isActive,
    required int createdAt,
  });

  Future<Either<Failure, void>> deleteProduct(String id);
}
