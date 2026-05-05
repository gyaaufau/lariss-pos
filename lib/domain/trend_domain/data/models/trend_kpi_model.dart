import '../../domain/entities/trend_kpi_entity.dart';

class TrendKpiModel extends TrendKpiEntity {
  const TrendKpiModel({
    required super.totalSales,
    required super.totalTransactions,
    required super.averageOrderValue,
    required super.salesComparison,
    required super.transactionsComparison,
  });
}
