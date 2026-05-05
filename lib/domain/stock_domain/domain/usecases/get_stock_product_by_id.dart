import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/stock_product_entity.dart';
import '../repositories/stock_repository.dart';

class GetStockProductById {
  const GetStockProductById(this._repository);

  final StockRepository _repository;

  Future<Either<Failure, StockProductEntity>> call(String productId) {
    return _repository.getProductById(productId);
  }
}
