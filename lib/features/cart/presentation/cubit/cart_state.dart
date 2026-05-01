import '../../../../domain/cart_domain/domain/entities/cart_item_entity.dart';

class CartState {
  const CartState({
    this.items = const <CartItemEntity>[],
    this.totalAmount = 0,
    this.totalItems = 0,
    this.errorMessage,
  });

  final List<CartItemEntity> items;
  final int totalAmount;
  final int totalItems;
  final String? errorMessage;

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItemEntity>? items,
    int? totalAmount,
    int? totalItems,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CartState(
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
