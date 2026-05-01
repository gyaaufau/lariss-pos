// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_dao.dart';

// ignore_for_file: type=lint
mixin _$TransactionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TransactionsTableTable get transactionsTable =>
      attachedDatabase.transactionsTable;
  $CategoriesTableTable get categoriesTable => attachedDatabase.categoriesTable;
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  $TransactionItemsTableTable get transactionItemsTable =>
      attachedDatabase.transactionItemsTable;
  TransactionsDaoManager get managers => TransactionsDaoManager(this);
}

class TransactionsDaoManager {
  final _$TransactionsDaoMixin _db;
  TransactionsDaoManager(this._db);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(
        _db.attachedDatabase,
        _db.transactionsTable,
      );
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(
        _db.attachedDatabase,
        _db.categoriesTable,
      );
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
  $$TransactionItemsTableTableTableManager get transactionItemsTable =>
      $$TransactionItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.transactionItemsTable,
      );
}
