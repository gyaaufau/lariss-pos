import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/stock_movement_entity.dart';
import '../repositories/stock_repository.dart';

class GetStockMovementsByProductId {
  const GetStockMovementsByProductId(this._repository);

  final StockRepository _repository;

  Future<Either<Failure, List<StockMovementEntity>>> call(String productId) {
    return _repository.getMovementsByProductId(productId);
  }
}
