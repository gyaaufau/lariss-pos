class StockProductEntity {
  const StockProductEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.sellingPrice,
    required this.currentStock,
    required this.minimumStock,
    required this.isActive,
  });

  final String id;
  final String categoryId;
  final String name;
  final int sellingPrice;
  final int currentStock;
  final int minimumStock;
  final bool isActive;

  bool get isLowStock => currentStock <= minimumStock;
  bool get isOutOfStock => currentStock <= 0;
}
