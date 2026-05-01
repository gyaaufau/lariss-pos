import 'package:drift/drift.dart';

import 'products_table.dart';

class StockMovementsTable extends Table {
  TextColumn get id => text()();

  TextColumn get productId => text().references(ProductsTable, #id)();

  TextColumn get type => text()();

  IntColumn get quantity => integer()();

  IntColumn get stockBefore => integer()();

  IntColumn get stockAfter => integer()();

  TextColumn get referenceId => text().nullable()();

  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
