import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  const GetProducts(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, List<ProductEntity>>> call() {
    return _repository.getProducts();
  }
}
