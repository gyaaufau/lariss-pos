import '../models/trend_summary_model.dart';

abstract class TrendLocalDatasource {
  Future<TrendSummaryModel> getTrendSummary();
}
