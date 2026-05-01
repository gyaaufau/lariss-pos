import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/stock_product_entity.dart';
import '../../domain/entities/stock_update_type.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_local_datasource.dart';
import '../datasources/stock_local_datasource_impl.dart';

class StockRepositoryImpl implements StockRepository {
  const StockRepositoryImpl(this._localDatasource);

  final StockLocalDatasource _localDatasource;

  @override
  Future<Either<Failure, List<StockProductEntity>>>
  getLowStockProducts() async {
    try {
      final products = await _localDatasource.getProducts();
      final lowStock = products.where((product) => product.isLowStock).toList();

      return right(lowStock);
    } catch (_) {
      return left(Failure('Gagal memuat produk low stock.'));
    }
  }

  @override
  Future<Either<Failure, List<StockProductEntity>>> getProducts() async {
    try {
      final products = await _localDatasource.getProducts();

      return right(products);
    } catch (_) {
      return left(Failure('Gagal memuat data stok.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateStock({
    required String productId,
    required StockUpdateType type,
    required int quantity,
  }) async {
    try {
      await _localDatasource.updateStock(
        productId: productId,
        type: type,
        quantity: quantity,
      );

      return right(unit);
    } on StockDatasourceException catch (error) {
      return left(Failure(error.message));
    } catch (_) {
      return left(Failure('Gagal mengubah stok.'));
    }
  }
}
