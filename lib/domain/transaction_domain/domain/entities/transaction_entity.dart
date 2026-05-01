import 'transaction_item_entity.dart';

class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.paidAmount,
    required this.changeAmount,
    required this.totalItem,
    required this.createdAt,
    this.items = const <TransactionItemEntity>[],
  });

  final String id;
  final String invoiceNumber;
  final int totalAmount;
  final int paidAmount;
  final int changeAmount;
  final int totalItem;
  final int createdAt;
  final List<TransactionItemEntity> items;
}
