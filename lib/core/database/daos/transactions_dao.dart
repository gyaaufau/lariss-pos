import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/transaction_items_table.dart';
import '../tables/transactions_table.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: <Type>[TransactionsTable, TransactionItemsTable])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.attachedDatabase);

  Future<List<TransactionsTableData>> getAll() {
    return (select(transactionsTable)
          ..orderBy(<OrderClauseGenerator<$TransactionsTableTable>>[
            (tbl) => OrderingTerm.desc(tbl.createdAt),
          ]))
        .get();
  }

  Future<List<TransactionItemsTableData>> getItemsByTransactionId(
    String transactionId,
  ) {
    return (select(transactionItemsTable)
          ..where((tbl) => tbl.transactionId.equals(transactionId))
          ..orderBy(<OrderClauseGenerator<$TransactionItemsTableTable>>[
            (tbl) => OrderingTerm.asc(tbl.createdAt),
          ]))
        .get();
  }

  Future<List<TransactionItemsTableData>> getAllItems() {
    return (select(transactionItemsTable)
          ..orderBy(<OrderClauseGenerator<$TransactionItemsTableTable>>[
            (tbl) => OrderingTerm.asc(tbl.createdAt),
          ]))
        .get();
  }

  Future<void> createTransaction(TransactionsTableCompanion entry) async {
    await into(transactionsTable).insert(entry);
  }

  Future<void> createTransactionItems(
    List<TransactionItemsTableCompanion> entries,
  ) async {
    await batch((Batch batch) {
      batch.insertAll(transactionItemsTable, entries);
    });
  }
}
