import 'package:flutter_test/flutter_test.dart';
import 'package:lariss/domain/cart_domain/domain/entities/cart_item_entity.dart';
import 'package:lariss/domain/transaction_domain/data/datasources/transaction_local_datasource.dart';
import 'package:lariss/domain/transaction_domain/data/models/transaction_item_model.dart';
import 'package:lariss/domain/transaction_domain/data/models/transaction_model.dart';
import 'package:lariss/domain/transaction_domain/data/repositories/transaction_repository_impl.dart';

void main() {
  late TransactionRepositoryImpl repository;
  late _FakeTransactionLocalDatasource datasource;

  const CartItemEntity cartItem = CartItemEntity(
    productId: 'prod_1',
    productName: 'Kopi Susu',
    price: 18000,
    quantity: 2,
    availableStock: 5,
  );

  setUp(() {
    datasource = _FakeTransactionLocalDatasource();
    repository = TransactionRepositoryImpl(datasource);
  });

  test('checkout gagal saat cart kosong', () async {
    final result = await repository.checkout(items: const [], paidAmount: 10000);

    expect(result.isLeft(), true);
    expect(result.swap().getOrElse((_) => throw UnimplementedError()).message, 'Cart masih kosong.');
  });

  test('checkout gagal saat pembayaran kurang', () async {
    final result = await repository.checkout(
      items: const <CartItemEntity>[cartItem],
      paidAmount: 10000,
    );

    expect(result.isLeft(), true);
    expect(
      result.swap().getOrElse((_) => throw UnimplementedError()).message,
      'Pembayaran kurang dari total belanja.',
    );
  });
}

class _FakeTransactionLocalDatasource implements TransactionLocalDatasource {
  @override
  Future<TransactionModel> checkout({
    required List<CartItemEntity> items,
    required int paidAmount,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionItemModel>> getTransactionItems(String transactionId) {
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionModel>> getTransactions() {
    throw UnimplementedError();
  }
}
