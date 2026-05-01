import '../../../cart_domain/domain/entities/cart_item_entity.dart';
import '../models/transaction_item_model.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDatasource {
  Future<List<TransactionModel>> getTransactions();

  Future<List<TransactionItemModel>> getTransactionItems(String transactionId);

  Future<TransactionModel> checkout({
    required List<CartItemEntity> items,
    required int paidAmount,
  });
}
