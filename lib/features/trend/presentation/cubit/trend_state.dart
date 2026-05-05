import '../../../../domain/trend_domain/domain/entities/trend_dashboard_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_date_filter_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_range.dart';

enum TrendStatus { initial, loading, success, failure }

class TrendState {
  const TrendState({
    this.status = TrendStatus.initial,
    this.selectedRange = TrendRange.daily,
    this.selectedFilter,
    this.dashboard,
    this.cache = const <String, TrendDashboardEntity>{},
    this.isRefreshing = false,
    this.errorMessage,
  });

  final TrendStatus status;
  final TrendRange selectedRange;
  final TrendDateFilterEntity? selectedFilter;
  final TrendDashboardEntity? dashboard;
  final Map<String, TrendDashboardEntity> cache;
  final bool isRefreshing;
  final String? errorMessage;

  TrendDashboardEntity? dashboardFor(
    TrendRange range, {
    TrendDateFilterEntity? filter,
  }) => cache[_cacheKey(range, filter)];

  TrendState copyWith({
    TrendStatus? status,
    TrendRange? selectedRange,
    TrendDateFilterEntity? selectedFilter,
    TrendDashboardEntity? dashboard,
    Map<String, TrendDashboardEntity>? cache,
    bool? isRefreshing,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool clearSelectedFilter = false,
  }) {
    return TrendState(
      status: status ?? this.status,
      selectedRange: selectedRange ?? this.selectedRange,
      selectedFilter: clearSelectedFilter
          ? null
          : selectedFilter ?? this.selectedFilter,
      dashboard: dashboard ?? this.dashboard,
      cache: cache ?? this.cache,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  static String cacheKey(TrendRange range, TrendDateFilterEntity? filter) =>
      _cacheKey(range, filter);

  static String _cacheKey(TrendRange range, TrendDateFilterEntity? filter) =>
      range == TrendRange.custom && filter != null
      ? 'custom:${filter.cacheKey}'
      : range.name;
}
