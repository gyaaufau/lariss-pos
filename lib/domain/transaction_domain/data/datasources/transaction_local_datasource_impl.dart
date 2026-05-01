import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/categories_dao.dart';
import '../../../../core/database/daos/products_dao.dart';
import '../../../../core/database/daos/stock_movements_dao.dart';
import '../../../../core/database/daos/transactions_dao.dart';
import '../../../cart_domain/domain/entities/cart_item_entity.dart';
import '../models/transaction_item_model.dart';
import '../models/transaction_model.dart';
import 'transaction_local_datasource.dart';

class TransactionLocalDatasourceImpl implements TransactionLocalDatasource {
  const TransactionLocalDatasourceImpl({
    required AppDatabase appDatabase,
    required TransactionsDao transactionsDao,
    required ProductsDao productsDao,
    required CategoriesDao categoriesDao,
    required StockMovementsDao stockMovementsDao,
  }) : _appDatabase = appDatabase,
       _transactionsDao = transactionsDao,
       _productsDao = productsDao,
       _categoriesDao = categoriesDao,
       _stockMovementsDao = stockMovementsDao;

  final AppDatabase _appDatabase;
  final TransactionsDao _transactionsDao;
  final ProductsDao _productsDao;
  final CategoriesDao _categoriesDao;
  final StockMovementsDao _stockMovementsDao;

  @override
  Future<TransactionModel> checkout({
    required List<CartItemEntity> items,
    required int paidAmount,
  }) async {
    if (items.isEmpty) {
      throw const TransactionDatasourceException('Cart masih kosong.');
    }

    final int totalAmount = items.fold<int>(
      0,
      (total, item) => total + item.subtotal,
    );

    if (paidAmount < totalAmount) {
      throw const TransactionDatasourceException('Pembayaran kurang.');
    }

    final int totalItem = items.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );
    final int now = DateTime.now().millisecondsSinceEpoch;
    final String transactionId = 'trx_$now';
    final String invoiceNumber = 'INV-$now';
    final int changeAmount = paidAmount - totalAmount;
    final List<_CheckoutProductSnapshot> snapshots =
        <_CheckoutProductSnapshot>[];

    for (final CartItemEntity item in items) {
      if (item.quantity <= 0) {
        throw TransactionDatasourceException(
          'Quantity ${item.productName} tidak valid.',
        );
      }

      final product = await _productsDao.getById(item.productId);

      if (product == null || product.deletedAt != null || !product.isActive) {
        throw TransactionDatasourceException(
          'Produk ${item.productName} tidak tersedia.',
        );
      }

      if (product.currentStock < item.quantity) {
        throw TransactionDatasourceException(
          'Stok ${product.name} tidak mencukupi.',
        );
      }

      final category = await _categoriesDao.getById(product.categoryId);

      snapshots.add(
        _CheckoutProductSnapshot(
          productId: product.id,
          productName: product.name,
          categoryName: category?.name ?? '-',
          productPrice: product.sellingPrice,
          quantity: item.quantity,
          subtotal: product.sellingPrice * item.quantity,
          stockBefore: product.currentStock,
          stockAfter: product.currentStock - item.quantity,
        ),
      );
    }

    await _appDatabase.transaction(() async {
      await _transactionsDao.createTransaction(
        TransactionsTableCompanion.insert(
          id: transactionId,
          invoiceNumber: invoiceNumber,
          totalAmount: totalAmount,
          paidAmount: paidAmount,
          changeAmount: changeAmount,
          totalItem: totalItem,
          createdAt: now,
        ),
      );

      await _transactionsDao.createTransactionItems(
        List<TransactionItemsTableCompanion>.generate(snapshots.length, (
          index,
        ) {
          final snapshot = snapshots[index];
          return TransactionItemsTableCompanion.insert(
            id: 'txi_${now}_$index',
            transactionId: transactionId,
            productId: snapshot.productId,
            productName: snapshot.productName,
            categoryName: snapshot.categoryName,
            productPrice: snapshot.productPrice,
            quantity: snapshot.quantity,
            subtotal: snapshot.subtotal,
            createdAt: now + index,
          );
        }, growable: false),
      );

      for (int index = 0; index < snapshots.length; index++) {
        final _CheckoutProductSnapshot snapshot = snapshots[index];

        await _productsDao.updateStock(
          productId: snapshot.productId,
          currentStock: snapshot.stockAfter,
          updatedAt: now + index,
        );

        await _stockMovementsDao.createMovement(
          StockMovementsTableCompanion.insert(
            id: 'stm_${now}_$index',
            productId: snapshot.productId,
            type: 'out',
            quantity: snapshot.quantity,
            stockBefore: snapshot.stockBefore,
            stockAfter: snapshot.stockAfter,
            referenceId: Value(transactionId),
            createdAt: now + index,
          ),
        );
      }
    });

    return TransactionModel(
      id: transactionId,
      invoiceNumber: invoiceNumber,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      changeAmount: changeAmount,
      totalItem: totalItem,
      createdAt: now,
      items: List<TransactionItemModel>.generate(snapshots.length, (index) {
        final _CheckoutProductSnapshot snapshot = snapshots[index];
        return TransactionItemModel(
          id: 'txi_${now}_$index',
          transactionId: transactionId,
          productId: snapshot.productId,
          productName: snapshot.productName,
          categoryName: snapshot.categoryName,
          productPrice: snapshot.productPrice,
          quantity: snapshot.quantity,
          subtotal: snapshot.subtotal,
          createdAt: now + index,
        );
      }, growable: false),
    );
  }

  @override
  Future<List<TransactionItemModel>> getTransactionItems(
    String transactionId,
  ) async {
    final items = await _transactionsDao.getItemsByTransactionId(transactionId);

    return items
        .map(TransactionItemModel.fromTableData)
        .toList(growable: false);
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final transactions = await _transactionsDao.getAll();

    return transactions
        .map(TransactionModel.fromTableData)
        .toList(growable: false);
  }
}

class TransactionDatasourceException implements Exception {
  const TransactionDatasourceException(this.message);

  final String message;
}

class _CheckoutProductSnapshot {
  const _CheckoutProductSnapshot({
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.productPrice,
    required this.quantity,
    required this.subtotal,
    required this.stockBefore,
    required this.stockAfter,
  });

  final String productId;
  final String productName;
  final String categoryName;
  final int productPrice;
  final int quantity;
  final int subtotal;
  final int stockBefore;
  final int stockAfter;
}
