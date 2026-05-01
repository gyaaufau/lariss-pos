import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/trend_summary_entity.dart';
import '../../domain/repositories/trend_repository.dart';
import '../datasources/trend_local_datasource.dart';

class TrendRepositoryImpl implements TrendRepository {
  const TrendRepositoryImpl(this._localDatasource);

  final TrendLocalDatasource _localDatasource;

  @override
  Future<Either<Failure, TrendSummaryEntity>> getTrendSummary() async {
    try {
      final summary = await _localDatasource.getTrendSummary();
      return right(summary);
    } catch (_) {
      return left(Failure('Gagal memuat trend penjualan.'));
    }
  }
}
