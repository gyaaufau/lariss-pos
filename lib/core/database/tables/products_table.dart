import 'package:drift/drift.dart';

import 'categories_table.dart';

class ProductsTable extends Table {
  TextColumn get id => text()();

  TextColumn get categoryId => text().references(CategoriesTable, #id)();

  TextColumn get name => text()();

  IntColumn get sellingPrice => integer()();

  IntColumn get currentStock => integer()();

  IntColumn get minimumStock => integer()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
