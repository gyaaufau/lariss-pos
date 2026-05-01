import '../../domain/entities/trend_summary_entity.dart';
import '../../domain/entities/daily_sales_entity.dart';
import '../../domain/entities/top_product_entity.dart';

class TrendSummaryModel extends TrendSummaryEntity {
  const TrendSummaryModel({
    required super.totalSales,
    required super.totalTransactions,
    required super.dailySales,
    required super.topProducts,
  });

  factory TrendSummaryModel.empty() {
    return const TrendSummaryModel(
      totalSales: 0,
      totalTransactions: 0,
      dailySales: <DailySalesEntity>[],
      topProducts: <TopProductEntity>[],
    );
  }
}
