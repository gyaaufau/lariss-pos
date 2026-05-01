import 'package:drift/drift.dart';

class CategoriesTable extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
