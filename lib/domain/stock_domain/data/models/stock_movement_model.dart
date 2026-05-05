import '../../../../core/database/app_database.dart';
import '../../domain/entities/stock_movement_entity.dart';

class StockMovementModel extends StockMovementEntity {
  const StockMovementModel({
    required super.id,
    required super.productId,
    required super.type,
    required super.quantity,
    required super.stockBefore,
    required super.stockAfter,
    required super.createdAt,
    super.referenceId,
  });

  factory StockMovementModel.fromTableData(StockMovementsTableData data) {
    return StockMovementModel(
      id: data.id,
      productId: data.productId,
      type: data.type,
      quantity: data.quantity,
      stockBefore: data.stockBefore,
      stockAfter: data.stockAfter,
      createdAt: data.createdAt,
      referenceId: data.referenceId,
    );
  }
}
