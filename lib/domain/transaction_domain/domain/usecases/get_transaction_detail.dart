import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionDetail {
  const GetTransactionDetail(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, TransactionEntity>> call(String transactionId) {
    return _repository.getTransactionDetail(transactionId);
  }
}
