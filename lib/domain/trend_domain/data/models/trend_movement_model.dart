import '../../domain/entities/trend_movement_entity.dart';

class TrendMovementModel extends TrendMovementEntity {
  const TrendMovementModel({
    required super.label,
    required super.currentQuantity,
    required super.previousQuantity,
    required super.currentSales,
    required super.previousSales,
  });
}
