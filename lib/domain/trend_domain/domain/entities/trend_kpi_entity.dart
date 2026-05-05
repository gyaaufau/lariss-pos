import 'trend_comparison_entity.dart';

class TrendKpiEntity {
  const TrendKpiEntity({
    required this.totalSales,
    required this.totalTransactions,
    required this.averageOrderValue,
    required this.salesComparison,
    required this.transactionsComparison,
  });

  final int totalSales;
  final int totalTransactions;
  final int averageOrderValue;
  final TrendComparisonEntity salesComparison;
  final TrendComparisonEntity transactionsComparison;
}
