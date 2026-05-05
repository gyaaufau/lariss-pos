import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/stock_movement_entity.dart';
import '../entities/stock_product_entity.dart';
import '../entities/stock_update_type.dart';

abstract class StockRepository {
  Future<Either<Failure, List<StockProductEntity>>> getProducts();

  Future<Either<Failure, StockProductEntity>> getProductById(String productId);

  Future<Either<Failure, List<StockMovementEntity>>> getMovementsByProductId(
    String productId,
  );

  Future<Either<Failure, List<StockProductEntity>>> getLowStockProducts();

  Future<Either<Failure, Unit>> updateStock({
    required String productId,
    required StockUpdateType type,
    required int quantity,
  });
}
