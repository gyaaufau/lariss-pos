import '../entities/cart_item_entity.dart';

class GetCartTotalItems {
  const GetCartTotalItems();

  int call(List<CartItemEntity> items) {
    return items.fold<int>(0, (total, item) => total + item.quantity);
  }
}
