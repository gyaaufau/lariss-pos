import '../../../../domain/transaction_domain/domain/entities/transaction_entity.dart';

enum CheckoutStatus { initial, submitting, success, failure }

class CheckoutState {
  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.transaction,
    this.errorMessage,
  });

  final CheckoutStatus status;
  final TransactionEntity? transaction;
  final String? errorMessage;

  CheckoutState copyWith({
    CheckoutStatus? status,
    TransactionEntity? transaction,
    String? errorMessage,
    bool clearTransaction = false,
    bool clearErrorMessage = false,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      transaction: clearTransaction
          ? null
          : transaction ?? this.transaction,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
