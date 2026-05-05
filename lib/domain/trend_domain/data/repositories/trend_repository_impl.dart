import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/trend_dashboard_entity.dart';
import '../../domain/entities/trend_date_filter_entity.dart';
import '../../domain/entities/trend_range.dart';
import '../../domain/repositories/trend_repository.dart';
import '../datasources/trend_local_datasource.dart';

class TrendRepositoryImpl implements TrendRepository {
  const TrendRepositoryImpl(this._localDatasource);

  final TrendLocalDatasource _localDatasource;

  @override
  Future<Either<Failure, TrendDashboardEntity>> getTrendDashboard(
    TrendRange range, {
    TrendDateFilterEntity? filter,
  }) async {
    try {
      final dashboard = await _localDatasource.getTrendDashboard(
        range,
        filter: filter,
      );
      return right(dashboard);
    } catch (_) {
      return left(Failure('Gagal memuat trend penjualan.'));
    }
  }
}
