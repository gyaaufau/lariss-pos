import '../../../cart_domain/domain/entities/cart_item_entity.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_local_datasource_impl.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._localDatasource);

  final TransactionLocalDatasource _localDatasource;

  @override
  Future<Either<Failure, TransactionEntity>> checkout({
    required List<CartItemEntity> items,
    required int paidAmount,
  }) async {
    try {
      if (items.isEmpty) {
        return left(Failure('Cart masih kosong.'));
      }

      final int totalAmount = items.fold<int>(
        0,
        (sum, item) => sum + item.subtotal,
      );

      if (paidAmount < totalAmount) {
        return left(Failure('Pembayaran kurang dari total belanja.'));
      }

      final transaction = await _localDatasource.checkout(
        items: items,
        paidAmount: paidAmount,
      );

      return right(transaction);
    } on TransactionDatasourceException catch (error) {
      return left(Failure(error.message));
    } catch (_) {
      return left(Failure('Checkout gagal diproses.'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransactionDetail(
    String transactionId,
  ) async {
    try {
      final transactions = await _localDatasource.getTransactions();
      final items = await _localDatasource.getTransactionItems(transactionId);

      final transaction = transactions
          .where((tx) => tx.id == transactionId)
          .firstOrNull;

      if (transaction == null) {
        return left(Failure('Detail transaksi tidak ditemukan.'));
      }

      return right(transaction.copyWith(items: items));
    } catch (_) {
      return left(Failure('Gagal memuat detail transaksi.'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions() async {
    try {
      final transactions = await _localDatasource.getTransactions();
      return right(transactions);
    } catch (_) {
      return left(Failure('Gagal memuat riwayat transaksi.'));
    }
  }
}
