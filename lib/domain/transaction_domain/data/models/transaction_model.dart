import '../../../../core/database/app_database.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_item_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.invoiceNumber,
    required super.totalAmount,
    required super.paidAmount,
    required super.changeAmount,
    required super.totalItem,
    required super.createdAt,
    super.items = const <TransactionItemEntity>[],
  });

  factory TransactionModel.fromTableData(
    TransactionsTableData data, {
    List<TransactionItemEntity> items = const <TransactionItemEntity>[],
  }) {
    return TransactionModel(
      id: data.id,
      invoiceNumber: data.invoiceNumber,
      totalAmount: data.totalAmount,
      paidAmount: data.paidAmount,
      changeAmount: data.changeAmount,
      totalItem: data.totalItem,
      createdAt: data.createdAt,
      items: items,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? invoiceNumber,
    int? totalAmount,
    int? paidAmount,
    int? changeAmount,
    int? totalItem,
    int? createdAt,
    List<TransactionItemEntity>? items,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      totalItem: totalItem ?? this.totalItem,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
