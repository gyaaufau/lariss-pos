// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movements_dao.dart';

// ignore_for_file: type=lint
mixin _$StockMovementsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTableTable get categoriesTable => attachedDatabase.categoriesTable;
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  $StockMovementsTableTable get stockMovementsTable =>
      attachedDatabase.stockMovementsTable;
  StockMovementsDaoManager get managers => StockMovementsDaoManager(this);
}

class StockMovementsDaoManager {
  final _$StockMovementsDaoMixin _db;
  StockMovementsDaoManager(this._db);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(
        _db.attachedDatabase,
        _db.categoriesTable,
      );
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
  $$StockMovementsTableTableTableManager get stockMovementsTable =>
      $$StockMovementsTableTableTableManager(
        _db.attachedDatabase,
        _db.stockMovementsTable,
      );
}
