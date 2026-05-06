import '../../domain/entities/trend_series_point_entity.dart';

class TrendSeriesPointModel extends TrendSeriesPointEntity {
  const TrendSeriesPointModel({
    required super.label,
    required super.shortLabel,
    required super.startAt,
    required super.endAt,
    required super.totalSales,
    required super.totalTransactions,
  });
}
