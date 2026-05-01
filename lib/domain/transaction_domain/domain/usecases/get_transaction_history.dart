import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionHistory {
  const GetTransactionHistory(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, List<TransactionEntity>>> call() {
    return _repository.getTransactions();
  }
}
