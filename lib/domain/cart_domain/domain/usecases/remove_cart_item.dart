import '../entities/cart_item_entity.dart';

class RemoveCartItem {
  const RemoveCartItem();

  List<CartItemEntity> call({
    required List<CartItemEntity> items,
    required String productId,
  }) {
    return items
        .where((item) => item.productId != productId)
        .toList(growable: false);
  }
}
