import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../product_domain/domain/entities/product_entity.dart';
import '../entities/cart_item_entity.dart';

class AddCartItem {
  const AddCartItem();

  Either<Failure, List<CartItemEntity>> call({
    required List<CartItemEntity> items,
    required ProductEntity product,
  }) {
    if (!product.isActive) {
      return left(Failure('Produk sedang nonaktif.'));
    }

    if (product.currentStock <= 0) {
      return left(Failure('Stok ${product.name} habis.'));
    }

    final int index = items.indexWhere((item) => item.productId == product.id);

    if (index == -1) {
      return right(<CartItemEntity>[
        ...items,
        CartItemEntity(
          productId: product.id,
          productName: product.name,
          price: product.sellingPrice,
          quantity: 1,
          availableStock: product.currentStock,
        ),
      ]);
    }

    final CartItemEntity existingItem = items[index];
    final int nextQuantity = existingItem.quantity + 1;

    if (nextQuantity > product.currentStock) {
      return left(Failure('Jumlah ${product.name} melebihi stok tersedia.'));
    }

    return right(
      items
          .map(
            (item) => item.productId == product.id
                ? item.copyWith(
                    quantity: nextQuantity,
                    availableStock: product.currentStock,
                  )
                : item,
          )
          .toList(growable: false),
    );
  }
}
