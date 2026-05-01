import 'package:drift/drift.dart';

import 'products_table.dart';
import 'transactions_table.dart';

class TransactionItemsTable extends Table {
  TextColumn get id => text()();

  TextColumn get transactionId => text().references(TransactionsTable, #id)();

  TextColumn get productId => text().references(ProductsTable, #id)();

  TextColumn get productName => text()();

  TextColumn get categoryName => text()();

  IntColumn get productPrice => integer()();

  IntColumn get quantity => integer()();

  IntColumn get subtotal => integer()();

  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
