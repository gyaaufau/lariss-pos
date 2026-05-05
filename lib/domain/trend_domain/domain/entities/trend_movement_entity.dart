class TrendMovementEntity {
  const TrendMovementEntity({
    required this.label,
    required this.currentQuantity,
    required this.previousQuantity,
    required this.currentSales,
    required this.previousSales,
  });

  final String label;
  final int currentQuantity;
  final int previousQuantity;
  final int currentSales;
  final int previousSales;

  int get quantityDelta => currentQuantity - previousQuantity;
  int get salesDelta => currentSales - previousSales;
}
