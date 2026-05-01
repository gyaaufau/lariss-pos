import 'package:drift/drift.dart';

class StoreProfileTable extends Table {
  TextColumn get id => text()();

  TextColumn get storeName => text()();

  TextColumn get ownerName => text()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
