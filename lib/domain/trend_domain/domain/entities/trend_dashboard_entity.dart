import 'trend_breakdown_entity.dart';
import 'trend_date_filter_entity.dart';
import 'trend_insight_entity.dart';
import 'trend_kpi_entity.dart';
import 'trend_movement_entity.dart';
import 'trend_range.dart';
import 'trend_series_point_entity.dart';

class TrendDashboardEntity {
  const TrendDashboardEntity({
    required this.range,
    required this.dateFilter,
    required this.kpi,
    required this.revenueSeries,
    required this.transactionSeries,
    required this.busyHours,
    required this.topProducts,
    required this.topCategories,
    required this.productDrops,
    required this.categoryDrops,
    required this.insights,
  });

  final TrendRange range;
  final TrendDateFilterEntity? dateFilter;
  final TrendKpiEntity kpi;
  final List<TrendSeriesPointEntity> revenueSeries;
  final List<TrendSeriesPointEntity> transactionSeries;
  final List<TrendBreakdownEntity> busyHours;
  final List<TrendBreakdownEntity> topProducts;
  final List<TrendBreakdownEntity> topCategories;
  final List<TrendMovementEntity> productDrops;
  final List<TrendMovementEntity> categoryDrops;
  final List<TrendInsightEntity> insights;

  bool get hasActivity =>
      kpi.totalSales > 0 ||
      kpi.totalTransactions > 0 ||
      busyHours.isNotEmpty ||
      topProducts.isNotEmpty ||
      topCategories.isNotEmpty;
}
