import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/cart_domain/domain/usecases/add_cart_item.dart';
import '../../../../domain/cart_domain/domain/usecases/get_cart_total_amount.dart';
import '../../../../domain/cart_domain/domain/usecases/get_cart_total_items.dart';
import '../../../../domain/cart_domain/domain/usecases/remove_cart_item.dart';
import '../../../../domain/cart_domain/domain/usecases/update_cart_item_quantity.dart';
import '../../../../domain/cart_domain/domain/entities/cart_item_entity.dart';
import '../../../../domain/product_domain/domain/entities/product_entity.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({
    required AddCartItem addCartItem,
    required RemoveCartItem removeCartItem,
    required UpdateCartItemQuantity updateCartItemQuantity,
    required GetCartTotalAmount getCartTotalAmount,
    required GetCartTotalItems getCartTotalItems,
  }) : _addCartItem = addCartItem,
       _removeCartItem = removeCartItem,
       _updateCartItemQuantity = updateCartItemQuantity,
       _getCartTotalAmount = getCartTotalAmount,
       _getCartTotalItems = getCartTotalItems,
       super(const CartState());

  final AddCartItem _addCartItem;
  final RemoveCartItem _removeCartItem;
  final UpdateCartItemQuantity _updateCartItemQuantity;
  final GetCartTotalAmount _getCartTotalAmount;
  final GetCartTotalItems _getCartTotalItems;

  void addItem(ProductEntity product) {
    final result = _addCartItem(items: state.items, product: product);

    result.match(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      _emitWithItems,
    );
  }

  void removeItem(String productId) {
    final items = _removeCartItem(items: state.items, productId: productId);
    _emitWithItems(items);
  }

  void incrementQuantity(String productId) {
    final CartItemEntity? item = _findItem(productId);

    if (item == null) {
      return;
    }

    updateQuantity(productId: productId, quantity: item.quantity + 1);
  }

  void decrementQuantity(String productId) {
    final CartItemEntity? item = _findItem(productId);

    if (item == null) {
      return;
    }

    updateQuantity(productId: productId, quantity: item.quantity - 1);
  }

  void updateQuantity({required String productId, required int quantity}) {
    final result = _updateCartItemQuantity(
      items: state.items,
      productId: productId,
      quantity: quantity,
    );

    result.match(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      _emitWithItems,
    );
  }

  void clearError() {
    emit(state.copyWith(clearErrorMessage: true));
  }

  void clear() {
    _emitWithItems(const <CartItemEntity>[]);
  }

  void clearCart() {
    _emitWithItems(const <CartItemEntity>[]);
  }

  CartItemEntity? _findItem(String productId) {
    for (final CartItemEntity item in state.items) {
      if (item.productId == productId) {
        return item;
      }
    }

    return null;
  }

  void _emitWithItems(List<CartItemEntity> items) {
    emit(
      state.copyWith(
        items: items,
        totalAmount: _getCartTotalAmount(items),
        totalItems: _getCartTotalItems(items),
        clearErrorMessage: true,
      ),
    );
  }
}
