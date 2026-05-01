import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/product_repository.dart';

class DeleteProduct {
  const DeleteProduct(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, void>> call(String productId) {
    return _repository.deleteProduct(productId);
  }
}
