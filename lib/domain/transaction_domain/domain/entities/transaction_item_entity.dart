class TransactionItemEntity {
  const TransactionItemEntity({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.productPrice,
    required this.quantity,
    required this.subtotal,
    required this.createdAt,
  });

  final String id;
  final String transactionId;
  final String productId;
  final String productName;
  final String categoryName;
  final int productPrice;
  final int quantity;
  final int subtotal;
  final int createdAt;
}
