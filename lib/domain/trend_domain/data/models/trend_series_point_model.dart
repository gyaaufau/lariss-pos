import '../../domain/entities/trend_series_point_entity.dart';

class TrendSeriesPointModel extends TrendSeriesPointEntity {
  const TrendSeriesPointModel({
    required super.label,
    required super.shortLabel,
    required super.totalSales,
    required super.totalTransactions,
  });
}
