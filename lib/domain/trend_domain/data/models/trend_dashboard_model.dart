import '../../domain/entities/trend_dashboard_entity.dart';
import '../../domain/entities/trend_range.dart';
import '../../domain/entities/trend_breakdown_entity.dart';
import '../../domain/entities/trend_comparison_entity.dart';
import '../../domain/entities/trend_insight_entity.dart';
import '../../domain/entities/trend_kpi_entity.dart';
import '../../domain/entities/trend_movement_entity.dart';
import '../../domain/entities/trend_series_point_entity.dart';

class TrendDashboardModel extends TrendDashboardEntity {
  const TrendDashboardModel({
    required super.range,
    required super.dateFilter,
    required super.kpi,
    required super.revenueSeries,
    required super.transactionSeries,
    required super.busyHours,
    required super.topProducts,
    required super.topCategories,
    required super.productDrops,
    required super.categoryDrops,
    required super.insights,
  });

  factory TrendDashboardModel.empty(TrendRange range) {
    return TrendDashboardModel(
      range: range,
      dateFilter: null,
      kpi: const TrendKpiEntity(
        totalSales: 0,
        totalTransactions: 0,
        averageOrderValue: 0,
        salesComparison: TrendComparisonEntity(currentValue: 0, previousValue: 0),
        transactionsComparison: TrendComparisonEntity(
          currentValue: 0,
          previousValue: 0,
        ),
      ),
      revenueSeries: const <TrendSeriesPointEntity>[],
      transactionSeries: const <TrendSeriesPointEntity>[],
      busyHours: const <TrendBreakdownEntity>[],
      topProducts: const <TrendBreakdownEntity>[],
      topCategories: const <TrendBreakdownEntity>[],
      productDrops: const <TrendMovementEntity>[],
      categoryDrops: const <TrendMovementEntity>[],
      insights: const <TrendInsightEntity>[],
    );
  }
}
