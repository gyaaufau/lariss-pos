import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/trend_summary_entity.dart';
import '../repositories/trend_repository.dart';

class GetTrendSummary {
  const GetTrendSummary(this._repository);

  final TrendRepository _repository;

  Future<Either<Failure, TrendSummaryEntity>> call() {
    return _repository.getTrendSummary();
  }
}
