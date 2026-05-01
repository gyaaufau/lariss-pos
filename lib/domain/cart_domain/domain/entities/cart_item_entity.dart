class CartItemEntity {
  const CartItemEntity({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.availableStock,
  });

  final String productId;
  final String productName;
  final int price;
  final int quantity;
  final int availableStock;

  int get subtotal => price * quantity;

  CartItemEntity copyWith({
    String? productId,
    String? productName,
    int? price,
    int? quantity,
    int? availableStock,
  }) {
    return CartItemEntity(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      availableStock: availableStock ?? this.availableStock,
    );
  }
}
