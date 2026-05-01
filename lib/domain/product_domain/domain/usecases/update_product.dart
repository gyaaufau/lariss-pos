import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  const UpdateProduct(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, ProductEntity>> call(UpdateProductParams params) {
    return _repository.updateProduct(
      id: params.id,
      categoryId: params.categoryId,
      name: params.name,
      sellingPrice: params.sellingPrice,
      currentStock: params.currentStock,
      minimumStock: params.minimumStock,
      isActive: params.isActive,
      createdAt: params.createdAt,
    );
  }
}

class UpdateProductParams {
  const UpdateProductParams({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.sellingPrice,
    required this.currentStock,
    required this.minimumStock,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String categoryId;
  final String name;
  final int sellingPrice;
  final int currentStock;
  final int minimumStock;
  final bool isActive;
  final int createdAt;
}
