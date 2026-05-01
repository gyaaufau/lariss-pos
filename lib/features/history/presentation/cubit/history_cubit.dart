import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/transaction_domain/domain/entities/transaction_entity.dart';
import '../../../../domain/transaction_domain/domain/usecases/get_transaction_detail.dart';
import '../../../../domain/transaction_domain/domain/usecases/get_transaction_history.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({
    required GetTransactionHistory getTransactionHistory,
    required GetTransactionDetail getTransactionDetail,
  }) : _getTransactionHistory = getTransactionHistory,
       _getTransactionDetail = getTransactionDetail,
       super(const HistoryState());

  final GetTransactionHistory _getTransactionHistory;
  final GetTransactionDetail _getTransactionDetail;

  Future<void> loadHistory() async {
    emit(
      state.copyWith(status: HistoryStatus.loading, clearErrorMessage: true),
    );

    final result = await _getTransactionHistory();

    result.match(
      (failure) => emit(
        state.copyWith(
          status: HistoryStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (transactions) => emit(
        state.copyWith(
          status: HistoryStatus.success,
          transactions: transactions,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<TransactionEntity?> getDetail(String transactionId) async {
    emit(
      state.copyWith(
        status: HistoryStatus.loadingDetail,
        clearErrorMessage: true,
      ),
    );

    final result = await _getTransactionDetail(transactionId);

    return result.match(
      (failure) {
        emit(
          state.copyWith(
            status: HistoryStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return null;
      },
      (detail) {
        emit(
          state.copyWith(
            status: HistoryStatus.success,
            clearErrorMessage: true,
          ),
        );
        return detail;
      },
    );
  }
}
