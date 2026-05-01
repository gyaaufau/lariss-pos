import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/cart_domain/domain/entities/cart_item_entity.dart';
import '../../../../domain/transaction_domain/domain/entities/transaction_entity.dart';
import '../../../../domain/transaction_domain/domain/usecases/checkout_transaction.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({required CheckoutTransaction checkoutTransaction})
    : _checkoutTransaction = checkoutTransaction,
      super(const CheckoutState());

  final CheckoutTransaction _checkoutTransaction;

  Future<TransactionEntity?> checkout({
    required List<CartItemEntity> items,
    required int paidAmount,
  }) async {
    emit(
      state.copyWith(
        status: CheckoutStatus.submitting,
        clearErrorMessage: true,
        clearTransaction: true,
      ),
    );

    final result = await _checkoutTransaction(
      CheckoutTransactionParams(items: items, paidAmount: paidAmount),
    );

    return result.match(
      (failure) {
        emit(
          state.copyWith(
            status: CheckoutStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return null;
      },
      (transaction) {
        emit(
          state.copyWith(
            status: CheckoutStatus.success,
            transaction: transaction,
            clearErrorMessage: true,
          ),
        );
        return transaction;
      },
    );
  }

  void reset() {
    emit(
      state.copyWith(
        status: CheckoutStatus.initial,
        clearErrorMessage: true,
        clearTransaction: true,
      ),
    );
  }
}
