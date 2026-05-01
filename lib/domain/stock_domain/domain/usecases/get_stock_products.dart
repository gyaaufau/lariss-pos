import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/stock_product_entity.dart';
import '../repositories/stock_repository.dart';

class GetStockProducts {
  const GetStockProducts(this._repository);

  final StockRepository _repository;

  Future<Either<Failure, List<StockProductEntity>>> call() {
    return _repository.getProducts();
  }
}
