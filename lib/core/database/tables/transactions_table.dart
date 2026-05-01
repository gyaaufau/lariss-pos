import 'package:drift/drift.dart';

class TransactionsTable extends Table {
  TextColumn get id => text()();

  TextColumn get invoiceNumber => text()();

  IntColumn get totalAmount => integer()();

  IntColumn get paidAmount => integer()();

  IntColumn get changeAmount => integer()();

  IntColumn get totalItem => integer()();

  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
