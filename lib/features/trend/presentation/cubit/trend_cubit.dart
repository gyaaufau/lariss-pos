import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/trend_domain/domain/entities/trend_dashboard_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_date_filter_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_range.dart';
import '../../../../domain/trend_domain/domain/usecases/get_trend_dashboard.dart';
import 'trend_state.dart';

class TrendCubit extends Cubit<TrendState> {
  TrendCubit({required GetTrendDashboard getTrendDashboard})
    : _getTrendDashboard = getTrendDashboard,
      super(const TrendState());

  final GetTrendDashboard _getTrendDashboard;

  Future<void> loadTrend({
    TrendRange? range,
    TrendDateFilterEntity? filter,
    bool forceRefresh = false,
  }) async {
    final TrendRange targetRange = range ?? state.selectedRange;
    final TrendDateFilterEntity? targetFilter = targetRange == TrendRange.custom
        ? filter ?? state.selectedFilter
        : null;
    final TrendDashboardEntity? cached = state.dashboardFor(
      targetRange,
      filter: targetFilter,
    );

    if (cached != null && !forceRefresh) {
      emit(
        state.copyWith(
          status: TrendStatus.success,
          selectedRange: targetRange,
          selectedFilter: targetFilter,
          dashboard: cached,
          isRefreshing: false,
          clearSelectedFilter: targetRange != TrendRange.custom,
          clearErrorMessage: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: cached == null ? TrendStatus.loading : TrendStatus.success,
        selectedRange: targetRange,
        selectedFilter: targetFilter,
        dashboard: cached,
        isRefreshing: cached != null,
        clearSelectedFilter: targetRange != TrendRange.custom,
        clearErrorMessage: true,
      ),
    );

    final result = await _getTrendDashboard(targetRange, filter: targetFilter);
    result.match(
      (failure) => emit(
        state.copyWith(
          status: TrendStatus.failure,
          isRefreshing: false,
          errorMessage: failure.message,
        ),
      ),
      (dashboard) => emit(
        state.copyWith(
          status: TrendStatus.success,
          dashboard: dashboard,
          selectedFilter: dashboard.dateFilter,
          cache: <String, TrendDashboardEntity>{
            ...state.cache,
            TrendState.cacheKey(targetRange, dashboard.dateFilter): dashboard,
          },
          isRefreshing: false,
          clearSelectedFilter: targetRange != TrendRange.custom,
          clearErrorMessage: true,
        ),
      ),
    );
  }
}
