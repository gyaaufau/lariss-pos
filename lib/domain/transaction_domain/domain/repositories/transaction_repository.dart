import '../../../cart_domain/domain/entities/cart_item_entity.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();

  Future<Either<Failure, TransactionEntity>> getTransactionDetail(
    String transactionId,
  );

  Future<Either<Failure, TransactionEntity>> checkout({
    required List<CartItemEntity> items,
    required int paidAmount,
  });
}
