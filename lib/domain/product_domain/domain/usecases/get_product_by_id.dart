import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductById {
  const GetProductById(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, ProductEntity>> call(String id) {
    return _repository.getProductById(id);
  }
}
