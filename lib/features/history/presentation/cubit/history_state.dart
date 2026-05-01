import '../../../../domain/transaction_domain/domain/entities/transaction_entity.dart';

enum HistoryStatus { initial, loading, success, failure, loadingDetail }

class HistoryState {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.transactions = const <TransactionEntity>[],
    this.errorMessage,
  });

  final HistoryStatus status;
  final List<TransactionEntity> transactions;
  final String? errorMessage;

  HistoryState copyWith({
    HistoryStatus? status,
    List<TransactionEntity>? transactions,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
