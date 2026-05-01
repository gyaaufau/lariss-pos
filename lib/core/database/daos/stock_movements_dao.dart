import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/stock_movements_table.dart';

part 'stock_movements_dao.g.dart';

@DriftAccessor(tables: <Type>[StockMovementsTable])
class StockMovementsDao extends DatabaseAccessor<AppDatabase>
    with _$StockMovementsDaoMixin {
  StockMovementsDao(super.attachedDatabase);

  Future<List<StockMovementsTableData>> getByProductId(String productId) {
    return (select(stockMovementsTable)
          ..where((tbl) => tbl.productId.equals(productId))
          ..orderBy(<OrderClauseGenerator<$StockMovementsTableTable>>[
            (tbl) => OrderingTerm.desc(tbl.createdAt),
          ]))
        .get();
  }

  Future<void> createMovement(StockMovementsTableCompanion entry) async {
    await into(stockMovementsTable).insert(entry);
  }
}
