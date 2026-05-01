import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class CreateProduct {
  const CreateProduct(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, ProductEntity>> call(CreateProductParams params) {
    return _repository.createProduct(
      categoryId: params.categoryId,
      name: params.name,
      sellingPrice: params.sellingPrice,
      currentStock: params.currentStock,
      minimumStock: params.minimumStock,
      isActive: params.isActive,
    );
  }
}

class CreateProductParams {
  const CreateProductParams({
    required this.categoryId,
    required this.name,
    required this.sellingPrice,
    required this.currentStock,
    required this.minimumStock,
    this.isActive = true,
  });

  final String categoryId;
  final String name;
  final int sellingPrice;
  final int currentStock;
  final int minimumStock;
  final bool isActive;
}
