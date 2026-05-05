import '../../domain/entities/trend_date_filter_entity.dart';
import '../../domain/entities/trend_range.dart';
import '../models/trend_dashboard_model.dart';

abstract class TrendLocalDatasource {
  Future<TrendDashboardModel> getTrendDashboard(
    TrendRange range, {
    TrendDateFilterEntity? filter,
  });
}
