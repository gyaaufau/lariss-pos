import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/stock_domain/domain/entities/stock_movement_entity.dart';
import '../../../../domain/stock_domain/domain/entities/stock_product_entity.dart';
import '../../../../domain/stock_domain/domain/usecases/get_stock_movements_by_product_id.dart';
import '../../../../domain/stock_domain/domain/usecases/get_stock_product_by_id.dart';

enum StockDetailStatus { initial, loading, success, failure }

class StockDetailState {
  const StockDetailState({
    this.status = StockDetailStatus.initial,
    this.product,
    this.movements = const <StockMovementEntity>[],
    this.errorMessage,
  });

  final StockDetailStatus status;
  final StockProductEntity? product;
  final List<StockMovementEntity> movements;
  final String? errorMessage;

  StockDetailState copyWith({
    StockDetailStatus? status,
    StockProductEntity? product,
    List<StockMovementEntity>? movements,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return StockDetailState(
      status: status ?? this.status,
      product: product ?? this.product,
      movements: movements ?? this.movements,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class StockDetailCubit extends Cubit<StockDetailState> {
  StockDetailCubit({
    required GetStockProductById getStockProductById,
    required GetStockMovementsByProductId getStockMovementsByProductId,
  }) : _getStockProductById = getStockProductById,
       _getStockMovementsByProductId = getStockMovementsByProductId,
       super(const StockDetailState());

  final GetStockProductById _getStockProductById;
  final GetStockMovementsByProductId _getStockMovementsByProductId;

  Future<void> loadDetail(String productId) async {
    emit(
      state.copyWith(
        status: StockDetailStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final productResult = await _getStockProductById(productId);
    final movementsResult = await _getStockMovementsByProductId(productId);

    productResult.match(
      (failure) => emit(
        state.copyWith(
          status: StockDetailStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (product) => movementsResult.match(
        (failure) => emit(
          state.copyWith(
            status: StockDetailStatus.failure,
            product: product,
            errorMessage: failure.message,
          ),
        ),
        (movements) => emit(
          state.copyWith(
            status: StockDetailStatus.success,
            product: product,
            movements: movements,
            clearErrorMessage: true,
          ),
        ),
      ),
    );
  }
}
