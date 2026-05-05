class StockMovementEntity {
  const StockMovementEntity({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    required this.createdAt,
    this.referenceId,
  });

  final String id;
  final String productId;
  final String type;
  final int quantity;
  final int stockBefore;
  final int stockAfter;
  final int createdAt;
  final String? referenceId;
}
