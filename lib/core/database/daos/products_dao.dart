import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/products_table.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: <Type>[ProductsTable])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(super.attachedDatabase);

  Future<List<ProductsTableData>> getAll() {
    return (select(productsTable)
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$ProductsTableTable>>[
            (tbl) => OrderingTerm.asc(tbl.name),
          ]))
        .get();
  }

  Future<List<ProductsTableData>> getAllActive() {
    return (select(productsTable)
          ..where((tbl) => tbl.deletedAt.isNull() & tbl.isActive.equals(true))
          ..orderBy(<OrderClauseGenerator<$ProductsTableTable>>[
            (tbl) => OrderingTerm.asc(tbl.name),
          ]))
        .get();
  }

  Future<ProductsTableData?> getById(String productId) {
    return (select(productsTable)
          ..where((tbl) => tbl.id.equals(productId) & tbl.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<int> countByCategoryId(String categoryId) async {
    final countExpression = productsTable.id.count();
    final query = selectOnly(productsTable)
      ..addColumns([countExpression])
      ..where(
        productsTable.categoryId.equals(categoryId) &
            productsTable.deletedAt.isNull(),
      );

    final row = await query.getSingle();
    return row.read(countExpression) ?? 0;
  }

  Future<void> updateStock({
    required String productId,
    required int currentStock,
    required int updatedAt,
  }) async {
    await (update(
      productsTable,
    )..where((tbl) => tbl.id.equals(productId))).write(
      ProductsTableCompanion(
        currentStock: Value(currentStock),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> upsertProduct(ProductsTableCompanion entry) async {
    await into(productsTable).insertOnConflictUpdate(entry);
  }
}
