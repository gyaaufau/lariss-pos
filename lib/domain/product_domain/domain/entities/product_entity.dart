class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.sellingPrice,
    required this.currentStock,
    required this.minimumStock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String categoryId;
  final String name;
  final int sellingPrice;
  final int currentStock;
  final int minimumStock;
  final bool isActive;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  bool get isOutOfStock => currentStock <= 0;

  bool get isLowStock => currentStock > 0 && currentStock <= minimumStock;
}
