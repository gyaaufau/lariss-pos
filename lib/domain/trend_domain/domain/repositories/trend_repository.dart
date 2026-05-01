import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/trend_summary_entity.dart';

abstract class TrendRepository {
  Future<Either<Failure, TrendSummaryEntity>> getTrendSummary();
}
