import '../../../../core/database/daos/transactions_dao.dart';
import '../models/daily_sales_model.dart';
import '../models/top_product_model.dart';
import '../models/trend_summary_model.dart';
import 'trend_local_datasource.dart';

class TrendLocalDatasourceImpl implements TrendLocalDatasource {
  const TrendLocalDatasourceImpl(this._transactionsDao);

  final TransactionsDao _transactionsDao;

  @override
  Future<TrendSummaryModel> getTrendSummary() async {
    final transactions = await _transactionsDao.getAll();

    if (transactions.isEmpty) {
      return TrendSummaryModel.empty();
    }

    int totalSales = 0;
    final Map<String, _DailyAccumulator> dailyMap =
        <String, _DailyAccumulator>{};
    final Map<String, _ProductAccumulator> productMap =
        <String, _ProductAccumulator>{};

    for (final transaction in transactions) {
      totalSales += transaction.totalAmount;

      final date = DateTime.fromMillisecondsSinceEpoch(transaction.createdAt);
      final label =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      final daily = dailyMap.putIfAbsent(label, _DailyAccumulator.new);
      daily.totalSales += transaction.totalAmount;
      daily.totalTransactions += 1;

      final items = await _transactionsDao.getItemsByTransactionId(
        transaction.id,
      );
      for (final item in items) {
        final product = productMap.putIfAbsent(
          item.productName,
          () => _ProductAccumulator(item.productName),
        );
        product.totalQuantity += item.quantity;
        product.totalSales += item.subtotal;
      }
    }

    final dailySales = dailyMap.entries
        .map(
          (entry) => DailySalesModel(
            label: entry.key,
            totalSales: entry.value.totalSales,
            totalTransactions: entry.value.totalTransactions,
          ),
        )
        .toList(growable: false);

    final topProducts = productMap.values.toList()
      ..sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));

    return TrendSummaryModel(
      totalSales: totalSales,
      totalTransactions: transactions.length,
      dailySales: dailySales,
      topProducts: topProducts
          .take(5)
          .map(
            (item) => TopProductModel(
              productName: item.productName,
              totalQuantity: item.totalQuantity,
              totalSales: item.totalSales,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _DailyAccumulator {
  int totalSales = 0;
  int totalTransactions = 0;
}

class _ProductAccumulator {
  _ProductAccumulator(this.productName);

  final String productName;
  int totalQuantity = 0;
  int totalSales = 0;
}
