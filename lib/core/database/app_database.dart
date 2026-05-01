import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/categories_dao.dart';
import 'daos/profile_dao.dart';
import 'daos/products_dao.dart';
import 'daos/stock_movements_dao.dart';
import 'daos/transactions_dao.dart';
import 'tables/app_settings_table.dart';
import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/stock_movements_table.dart';
import 'tables/store_profile_table.dart';
import 'tables/transaction_items_table.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: <Type>[
    CategoriesTable,
    ProductsTable,
    StockMovementsTable,
    TransactionsTable,
    TransactionItemsTable,
    StoreProfileTable,
    AppSettingsTable,
  ],
  daos: <Type>[
    CategoriesDao,
    ProductsDao,
    StockMovementsDao,
    TransactionsDao,
    ProfileDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._();

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 2) {
        await migrator.createTable(storeProfileTable);
        await migrator.createTable(appSettingsTable);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(p.join(directory.path, 'lariss_pos.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
