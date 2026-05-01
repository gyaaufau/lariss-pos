import '../../../../domain/trend_domain/domain/entities/trend_summary_entity.dart';

enum TrendStatus { initial, loading, success, failure }

class TrendState {
  const TrendState({
    this.status = TrendStatus.initial,
    this.summary,
    this.errorMessage,
  });

  final TrendStatus status;
  final TrendSummaryEntity? summary;
  final String? errorMessage;

  TrendState copyWith({
    TrendStatus? status,
    TrendSummaryEntity? summary,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TrendState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
