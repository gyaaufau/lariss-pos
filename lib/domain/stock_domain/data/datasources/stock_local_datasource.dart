import '../../domain/entities/stock_update_type.dart';
import '../models/stock_product_model.dart';

abstract class StockLocalDatasource {
  Future<List<StockProductModel>> getProducts();

  Future<void> updateStock({
    required String productId,
    required StockUpdateType type,
    required int quantity,
  });
}
