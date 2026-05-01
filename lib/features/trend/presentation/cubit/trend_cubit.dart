import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/trend_domain/domain/usecases/get_trend_summary.dart';
import 'trend_state.dart';

class TrendCubit extends Cubit<TrendState> {
  TrendCubit({required GetTrendSummary getTrendSummary})
    : _getTrendSummary = getTrendSummary,
      super(const TrendState());

  final GetTrendSummary _getTrendSummary;

  Future<void> loadTrend() async {
    emit(state.copyWith(status: TrendStatus.loading, clearErrorMessage: true));

    final result = await _getTrendSummary();
    result.match(
      (failure) => emit(
        state.copyWith(
          status: TrendStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (summary) => emit(
        state.copyWith(
          status: TrendStatus.success,
          summary: summary,
          clearErrorMessage: true,
        ),
      ),
    );
  }
}
