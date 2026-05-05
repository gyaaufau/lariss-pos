import '../../domain/entities/stock_update_type.dart';
import '../models/stock_movement_model.dart';
import '../models/stock_product_model.dart';

abstract class StockLocalDatasource {
  Future<List<StockProductModel>> getProducts();

  Future<StockProductModel?> getProductById(String productId);

  Future<List<StockMovementModel>> getMovementsByProductId(String productId);

  Future<void> updateStock({
    required String productId,
    required StockUpdateType type,
    required int quantity,
  });
}
