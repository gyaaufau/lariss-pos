import 'package:drift/drift.dart';

class AppSettingsTable extends Table {
  TextColumn get id => text()();

  TextColumn get key => text()();

  TextColumn get value => text()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
