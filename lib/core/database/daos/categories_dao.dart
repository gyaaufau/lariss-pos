import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: <Type>[CategoriesTable])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.attachedDatabase);

  Future<List<CategoriesTableData>> getAll() {
    return (select(categoriesTable)
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$CategoriesTableTable>>[
            (tbl) => OrderingTerm.asc(tbl.name),
          ]))
        .get();
  }

  Future<CategoriesTableData?> getById(String categoryId) {
    return (select(
      categoriesTable,
    )..where((tbl) => tbl.id.equals(categoryId))).getSingleOrNull();
  }

  Future<void> upsertCategory(CategoriesTableCompanion entry) async {
    await into(categoriesTable).insertOnConflictUpdate(entry);
  }
}
