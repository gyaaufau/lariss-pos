import 'daily_sales_entity.dart';
import 'top_product_entity.dart';

class TrendSummaryEntity {
  const TrendSummaryEntity({
    required this.totalSales,
    required this.totalTransactions,
    required this.dailySales,
    required this.topProducts,
  });

  final int totalSales;
  final int totalTransactions;
  final List<DailySalesEntity> dailySales;
  final List<TopProductEntity> topProducts;
}
