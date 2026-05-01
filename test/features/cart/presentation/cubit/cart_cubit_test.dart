import 'package:flutter_test/flutter_test.dart';
import 'package:lariss/domain/cart_domain/domain/usecases/add_cart_item.dart';
import 'package:lariss/domain/cart_domain/domain/usecases/get_cart_total_amount.dart';
import 'package:lariss/domain/cart_domain/domain/usecases/get_cart_total_items.dart';
import 'package:lariss/domain/cart_domain/domain/usecases/remove_cart_item.dart';
import 'package:lariss/domain/cart_domain/domain/usecases/update_cart_item_quantity.dart';
import 'package:lariss/domain/product_domain/domain/entities/product_entity.dart';
import 'package:lariss/features/cart/presentation/cubit/cart_cubit.dart';

void main() {
  late CartCubit cartCubit;

  const ProductEntity coffee = ProductEntity(
    id: 'prod_1',
    categoryId: 'cat_1',
    name: 'Kopi Susu',
    sellingPrice: 18000,
    currentStock: 3,
    minimumStock: 1,
    isActive: true,
    createdAt: 1,
    updatedAt: 1,
  );

  setUp(() {
    cartCubit = CartCubit(
      addCartItem: const AddCartItem(),
      removeCartItem: const RemoveCartItem(),
      updateCartItemQuantity: const UpdateCartItemQuantity(),
      getCartTotalAmount: const GetCartTotalAmount(),
      getCartTotalItems: const GetCartTotalItems(),
    );
  });

  tearDown(() async {
    await cartCubit.close();
  });

  test('add item menghitung total item dan total harga', () {
    cartCubit.addItem(coffee);
    cartCubit.addItem(coffee);

    expect(cartCubit.state.items, hasLength(1));
    expect(cartCubit.state.items.first.quantity, 2);
    expect(cartCubit.state.totalItems, 2);
    expect(cartCubit.state.totalAmount, 36000);
  });

  test('increment di atas stok menampilkan error', () {
    cartCubit.addItem(coffee);
    cartCubit.addItem(coffee);
    cartCubit.addItem(coffee);
    cartCubit.addItem(coffee);

    expect(cartCubit.state.items.first.quantity, 3);
    expect(
      cartCubit.state.errorMessage,
      'Jumlah Kopi Susu melebihi stok tersedia.',
    );
  });

  test('decrement ke nol menghapus item dari cart', () {
    cartCubit.addItem(coffee);
    cartCubit.decrementQuantity(coffee.id);

    expect(cartCubit.state.items, isEmpty);
    expect(cartCubit.state.totalItems, 0);
    expect(cartCubit.state.totalAmount, 0);
  });

  test('remove item mengosongkan cart', () {
    cartCubit.addItem(coffee);
    cartCubit.removeItem(coffee.id);

    expect(cartCubit.state.items, isEmpty);
  });
}
