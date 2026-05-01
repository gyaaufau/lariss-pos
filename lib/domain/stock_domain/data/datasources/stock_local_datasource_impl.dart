import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/products_dao.dart';
import '../../../../core/database/daos/stock_movements_dao.dart';
import '../../domain/entities/stock_update_type.dart';
import '../models/stock_product_model.dart';
import 'stock_local_datasource.dart';

class StockLocalDatasourceImpl implements StockLocalDatasource {
  const StockLocalDatasourceImpl({
    required AppDatabase appDatabase,
    required ProductsDao productsDao,
    required StockMovementsDao stockMovementsDao,
  }) : _appDatabase = appDatabase,
       _productsDao = productsDao,
       _stockMovementsDao = stockMovementsDao;

  final AppDatabase _appDatabase;
  final ProductsDao _productsDao;
  final StockMovementsDao _stockMovementsDao;

  @override
  Future<List<StockProductModel>> getProducts() async {
    final products = await _productsDao.getAllActive();

    return products
        .map(StockProductModel.fromTableData)
        .toList(growable: false);
  }

  @override
  Future<void> updateStock({
    required String productId,
    required StockUpdateType type,
    required int quantity,
  }) async {
    final product = await _productsDao.getById(productId);

    if (product == null) {
      throw const StockDatasourceException('Produk tidak ditemukan.');
    }

    if (quantity < 0) {
      throw const StockDatasourceException('Jumlah stok tidak valid.');
    }

    final int currentStock = product.currentStock;
    late final int nextStock;
    late final int movementQuantity;

    switch (type) {
      case StockUpdateType.stockIn:
        if (quantity <= 0) {
          throw const StockDatasourceException(
            'Jumlah stock in harus di atas 0.',
          );
        }
        nextStock = currentStock + quantity;
        movementQuantity = quantity;
      case StockUpdateType.stockOut:
        if (quantity <= 0) {
          throw const StockDatasourceException(
            'Jumlah stock out harus di atas 0.',
          );
        }
        nextStock = currentStock - quantity;
        movementQuantity = quantity;
        if (nextStock < 0) {
          throw const StockDatasourceException('Stok tidak boleh minus.');
        }
      case StockUpdateType.adjustment:
        nextStock = quantity;
        movementQuantity = nextStock - currentStock;
        if (nextStock < 0) {
          throw const StockDatasourceException('Stok tidak boleh minus.');
        }
    }

    final int now = DateTime.now().millisecondsSinceEpoch;

    await _appDatabase.transaction(() async {
      await _productsDao.updateStock(
        productId: productId,
        currentStock: nextStock,
        updatedAt: now,
      );

      await _stockMovementsDao.createMovement(
        StockMovementsTableCompanion(
          id: Value('stm_$now'),
          productId: Value(productId),
          type: Value(type.value),
          quantity: Value(movementQuantity),
          stockBefore: Value(currentStock),
          stockAfter: Value(nextStock),
          createdAt: Value(now),
        ),
      );
    });
  }
}

class StockDatasourceException implements Exception {
  const StockDatasourceException(this.message);

  final String message;
}
