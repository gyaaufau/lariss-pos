import '../../../../core/database/app_database.dart';
import '../../domain/entities/transaction_item_entity.dart';

class TransactionItemModel extends TransactionItemEntity {
  const TransactionItemModel({
    required super.id,
    required super.transactionId,
    required super.productId,
    required super.productName,
    required super.categoryName,
    required super.productPrice,
    required super.quantity,
    required super.subtotal,
    required super.createdAt,
  });

  factory TransactionItemModel.fromTableData(TransactionItemsTableData data) {
    return TransactionItemModel(
      id: data.id,
      transactionId: data.transactionId,
      productId: data.productId,
      productName: data.productName,
      categoryName: data.categoryName,
      productPrice: data.productPrice,
      quantity: data.quantity,
      subtotal: data.subtotal,
      createdAt: data.createdAt,
    );
  }
}
