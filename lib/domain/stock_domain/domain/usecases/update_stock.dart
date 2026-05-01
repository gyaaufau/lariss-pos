import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/stock_update_type.dart';
import '../repositories/stock_repository.dart';

class UpdateStock {
  const UpdateStock(this._repository);

  final StockRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String productId,
    required StockUpdateType type,
    required int quantity,
  }) {
    return _repository.updateStock(
      productId: productId,
      type: type,
      quantity: quantity,
    );
  }
}
