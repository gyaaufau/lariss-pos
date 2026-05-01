import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/stock_domain/domain/entities/stock_update_type.dart';
import '../../../../domain/stock_domain/domain/usecases/get_low_stock_products.dart';
import '../../../../domain/stock_domain/domain/usecases/get_stock_products.dart';
import '../../../../domain/stock_domain/domain/usecases/update_stock.dart';
import 'stock_state.dart';

class StockCubit extends Cubit<StockState> {
  StockCubit({
    required GetStockProducts getStockProducts,
    required GetLowStockProducts getLowStockProducts,
    required UpdateStock updateStock,
  }) : _getStockProducts = getStockProducts,
       _getLowStockProducts = getLowStockProducts,
       _updateStock = updateStock,
       super(const StockState());

  final GetStockProducts _getStockProducts;
  final GetLowStockProducts _getLowStockProducts;
  final UpdateStock _updateStock;

  Future<void> loadStockOverview() async {
    emit(state.copyWith(status: StockStatus.loading, clearErrorMessage: true));

    final productsResult = await _getStockProducts();
    final lowStockResult = await _getLowStockProducts();

    productsResult.match(
      (failure) => emit(
        state.copyWith(
          status: StockStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (products) {
        lowStockResult.match(
          (failure) => emit(
            state.copyWith(
              status: StockStatus.failure,
              errorMessage: failure.message,
            ),
          ),
          (lowStockProducts) => emit(
            state.copyWith(
              status: StockStatus.success,
              products: products,
              lowStockProducts: lowStockProducts,
              clearErrorMessage: true,
            ),
          ),
        );
      },
    );
  }

  Future<bool> updateProductStock({
    required String productId,
    required StockUpdateType type,
    required int quantity,
  }) async {
    emit(
      state.copyWith(status: StockStatus.submitting, clearErrorMessage: true),
    );

    final result = await _updateStock(
      productId: productId,
      type: type,
      quantity: quantity,
    );

    return result.match(
      (failure) {
        emit(
          state.copyWith(
            status: StockStatus.failure,
            errorMessage: failure.message,
          ),
        );

        return false;
      },
      (_) async {
        await loadStockOverview();
        return true;
      },
    );
  }
}
