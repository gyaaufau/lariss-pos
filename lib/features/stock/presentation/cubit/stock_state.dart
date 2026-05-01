import '../../../../domain/stock_domain/domain/entities/stock_product_entity.dart';

enum StockStatus { initial, loading, success, failure, submitting }

class StockState {
  const StockState({
    this.status = StockStatus.initial,
    this.products = const <StockProductEntity>[],
    this.lowStockProducts = const <StockProductEntity>[],
    this.errorMessage,
  });

  final StockStatus status;
  final List<StockProductEntity> products;
  final List<StockProductEntity> lowStockProducts;
  final String? errorMessage;

  StockState copyWith({
    StockStatus? status,
    List<StockProductEntity>? products,
    List<StockProductEntity>? lowStockProducts,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return StockState(
      status: status ?? this.status,
      products: products ?? this.products,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
