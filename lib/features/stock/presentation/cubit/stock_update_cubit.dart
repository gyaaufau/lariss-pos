import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/stock_domain/domain/entities/stock_product_entity.dart';
import '../../../../domain/stock_domain/domain/entities/stock_update_type.dart';
import '../../../../domain/stock_domain/domain/usecases/get_stock_product_by_id.dart';
import '../../../../domain/stock_domain/domain/usecases/update_stock.dart';

enum StockUpdateStatus { initial, loading, ready, submitting, failure }

class StockUpdateState {
  const StockUpdateState({
    this.status = StockUpdateStatus.initial,
    this.product,
    this.errorMessage,
  });

  final StockUpdateStatus status;
  final StockProductEntity? product;
  final String? errorMessage;

  StockUpdateState copyWith({
    StockUpdateStatus? status,
    StockProductEntity? product,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return StockUpdateState(
      status: status ?? this.status,
      product: product ?? this.product,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class StockUpdateCubit extends Cubit<StockUpdateState> {
  StockUpdateCubit({
    required GetStockProductById getStockProductById,
    required UpdateStock updateStock,
  }) : _getStockProductById = getStockProductById,
       _updateStock = updateStock,
       super(const StockUpdateState());

  final GetStockProductById _getStockProductById;
  final UpdateStock _updateStock;

  Future<void> initialize(String productId) async {
    emit(
      state.copyWith(
        status: StockUpdateStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final result = await _getStockProductById(productId);
    result.match(
      (failure) => emit(
        state.copyWith(
          status: StockUpdateStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (product) => emit(
        state.copyWith(
          status: StockUpdateStatus.ready,
          product: product,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<bool> submit({
    required StockUpdateType type,
    required int quantity,
  }) async {
    final product = state.product;
    if (product == null) {
      emit(
        state.copyWith(
          status: StockUpdateStatus.failure,
          errorMessage: 'Produk tidak ditemukan.',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        status: StockUpdateStatus.submitting,
        clearErrorMessage: true,
      ),
    );

    final result = await _updateStock(
      productId: product.id,
      type: type,
      quantity: quantity,
    );

    return result.match((failure) {
      emit(
        state.copyWith(
          status: StockUpdateStatus.failure,
          errorMessage: failure.message,
        ),
      );
      return false;
    }, (_) => true);
  }
}
