import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/cart_item_entity.dart';

class UpdateCartItemQuantity {
  const UpdateCartItemQuantity();

  Either<Failure, List<CartItemEntity>> call({
    required List<CartItemEntity> items,
    required String productId,
    required int quantity,
  }) {
    if (quantity < 0) {
      return left(Failure('Quantity tidak valid.'));
    }

    final CartItemEntity? item = items.cast<CartItemEntity?>().firstWhere(
      (entry) => entry?.productId == productId,
      orElse: () => null,
    );

    if (item == null) {
      return right(items);
    }

    if (quantity == 0) {
      return right(
        items
            .where((entry) => entry.productId != productId)
            .toList(growable: false),
      );
    }

    if (quantity > item.availableStock) {
      return left(
        Failure('Jumlah ${item.productName} melebihi stok tersedia.'),
      );
    }

    return right(
      items
          .map(
            (entry) => entry.productId == productId
                ? entry.copyWith(quantity: quantity)
                : entry,
          )
          .toList(growable: false),
    );
  }
}
