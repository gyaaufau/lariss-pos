import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/stock_movement_entity.dart';
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
  Future<Either<Failure, StockProductEntity>> getProductById(
    String productId,
  ) async {
    try {
      if (productId.trim().isEmpty) {
        return left(Failure('Produk tidak valid.'));
      }

      final product = await _localDatasource.getProductById(productId);
      if (product == null) {
        return left(Failure('Produk stok tidak ditemukan.'));
      }

      return right(product);
    } catch (_) {
      return left(Failure('Gagal memuat detail stok.'));
    }
  }

  @override
  Future<Either<Failure, List<StockMovementEntity>>> getMovementsByProductId(
    String productId,
  ) async {
    try {
      if (productId.trim().isEmpty) {
        return left(Failure('Produk tidak valid.'));
      }

      final movements = await _localDatasource.getMovementsByProductId(
        productId,
      );
      return right(movements);
    } catch (_) {
      return left(Failure('Gagal memuat riwayat stok.'));
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
