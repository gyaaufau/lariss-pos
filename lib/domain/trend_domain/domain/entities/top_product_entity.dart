class TopProductEntity {
  const TopProductEntity({
    required this.productName,
    required this.totalQuantity,
    required this.totalSales,
  });

  final String productName;
  final int totalQuantity;
  final int totalSales;
}
