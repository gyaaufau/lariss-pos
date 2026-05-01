import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../cart_domain/domain/entities/cart_item_entity.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class CheckoutTransaction {
  const CheckoutTransaction(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, TransactionEntity>> call(
    CheckoutTransactionParams params,
  ) {
    return _repository.checkout(
      items: params.items,
      paidAmount: params.paidAmount,
    );
  }
}

class CheckoutTransactionParams {
  const CheckoutTransactionParams({
    required this.items,
    required this.paidAmount,
  });

  final List<CartItemEntity> items;
  final int paidAmount;
}
