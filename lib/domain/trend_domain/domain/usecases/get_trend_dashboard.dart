import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/trend_dashboard_entity.dart';
import '../entities/trend_date_filter_entity.dart';
import '../entities/trend_range.dart';
import '../repositories/trend_repository.dart';

class GetTrendDashboard {
  const GetTrendDashboard(this._repository);

  final TrendRepository _repository;

  Future<Either<Failure, TrendDashboardEntity>> call(
    TrendRange range, {
    TrendDateFilterEntity? filter,
  }) {
    return _repository.getTrendDashboard(range, filter: filter);
  }
}
