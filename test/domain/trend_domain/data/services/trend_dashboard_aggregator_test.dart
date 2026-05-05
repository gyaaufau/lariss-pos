import 'package:flutter_test/flutter_test.dart';
import 'package:lariss/domain/trend_domain/data/services/trend_dashboard_aggregator.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_date_filter_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_range.dart';
import 'package:lariss/domain/transaction_domain/data/models/transaction_item_model.dart';
import 'package:lariss/domain/transaction_domain/data/models/transaction_model.dart';

void main() {
  final TrendDashboardAggregator aggregator = TrendDashboardAggregator();
  final DateTime now = DateTime(2026, 5, 6, 14, 0);

  test('daily bucket per jam benar dan bucket kosong isi nol', () {
    final dashboard = aggregator.build(
      range: TrendRange.daily,
      transactions: <TransactionModel>[
        _transaction('t1', 10000, DateTime(2026, 5, 6, 9, 15)),
        _transaction('t2', 15000, DateTime(2026, 5, 6, 9, 45)),
        _transaction('t3', 20000, DateTime(2026, 5, 6, 14, 10)),
        _transaction('old', 99999, DateTime(2026, 5, 5, 14, 10)),
      ],
      items: <TransactionItemModel>[
        _item('i1', 't1', 'Americano', 'Kopi', 2, 10000),
        _item('i2', 't2', 'Latte', 'Kopi', 1, 15000),
        _item('i3', 't3', 'Croffle', 'Snack', 3, 20000),
      ],
      now: now,
    );

    expect(dashboard.kpi.totalSales, 45000);
    expect(dashboard.kpi.totalTransactions, 3);
    expect(dashboard.kpi.averageOrderValue, 15000);
    expect(dashboard.revenueSeries, hasLength(24));
    expect(dashboard.revenueSeries[9].totalSales, 25000);
    expect(dashboard.revenueSeries[9].totalTransactions, 2);
    expect(dashboard.revenueSeries[10].totalSales, 0);
    expect(dashboard.revenueSeries[14].totalSales, 20000);
    expect(dashboard.busyHours.first.label, '09:00');
    expect(dashboard.busyHours.first.totalQuantity, 2);
    expect(dashboard.insights.first.title, 'Puncak sales');
  });

  test('weekly filter 7 hari benar dan top breakdown urut desc qty', () {
    final dashboard = aggregator.build(
      range: TrendRange.weekly,
      transactions: <TransactionModel>[
        _transaction('prev1', 8000, DateTime(2026, 4, 29, 10)),
        _transaction('t1', 10000, DateTime(2026, 4, 30, 9)),
        _transaction('t2', 12000, DateTime(2026, 5, 2, 10)),
        _transaction('t3', 15000, DateTime(2026, 5, 6, 20)),
        _transaction('old', 5000, DateTime(2026, 4, 28, 12)),
      ],
      items: <TransactionItemModel>[
        _item('p1', 'prev1', 'Latte', 'Kopi', 5, 8000),
        _item('i1', 't1', 'Americano', 'Kopi', 1, 10000),
        _item('i2', 't2', 'Croffle', 'Snack', 4, 12000),
        _item('i3', 't3', 'Americano', 'Kopi', 2, 15000),
      ],
      now: now,
    );

    expect(dashboard.kpi.totalTransactions, 3);
    expect(
      dashboard.transactionSeries
          .fold<int>(0, (int sum, point) => sum + point.totalTransactions),
      3,
    );
    expect(dashboard.topProducts.first.label, 'Croffle');
    expect(dashboard.topProducts.first.totalQuantity, 4);
    expect(dashboard.busyHours.first.label, '20:00');
    expect(dashboard.busyHours.first.totalQuantity, 1);
    expect(dashboard.topCategories.first.label, 'Snack');
    expect(dashboard.topCategories.first.totalQuantity, 4);
    expect(dashboard.productDrops.first.label, 'Latte');
    expect(dashboard.productDrops.first.quantityDelta, -5);
    expect(dashboard.kpi.salesComparison.previousValue, 13000);
  });

  test('monthly rolling 30 hari dan yearly 12 bulan masuk bucket benar', () {
    final List<TransactionModel> transactions = <TransactionModel>[
      _transaction('m1', 11000, DateTime(2026, 4, 10, 9)),
      _transaction('m2', 13000, DateTime(2026, 4, 25, 9)),
      _transaction('m3', 17000, DateTime(2026, 5, 6, 9)),
      _transaction('y1', 22000, DateTime(2025, 6, 15, 9)),
      _transaction('y2', 33000, DateTime(2026, 1, 15, 9)),
    ];

    final List<TransactionItemModel> items = <TransactionItemModel>[
      _item('i1', 'm1', 'A', 'Kopi', 1, 11000),
      _item('i2', 'm2', 'B', 'Snack', 1, 13000),
      _item('i3', 'm3', 'C', 'Kopi', 1, 17000),
      _item('i4', 'y1', 'D', 'Teh', 1, 22000),
      _item('i5', 'y2', 'E', 'Snack', 1, 33000),
    ];

    final monthly = aggregator.build(
      range: TrendRange.monthly,
      transactions: transactions,
      items: items,
      now: now,
    );
    final yearly = aggregator.build(
      range: TrendRange.yearly,
      transactions: transactions,
      items: items,
      now: now,
    );

    expect(monthly.kpi.totalTransactions, 3);
    expect(monthly.revenueSeries, hasLength(5));
    expect(yearly.kpi.totalTransactions, 5);
    expect(yearly.revenueSeries, hasLength(12));
    expect(
      yearly.revenueSeries
          .fold<int>(0, (int sum, point) => sum + point.totalSales),
      96000,
    );
    expect(monthly.kpi.salesComparison.currentValue, 41000);
  });

  test('custom range bucket harian dan compare span sama', () {
    final dashboard = aggregator.build(
      range: TrendRange.custom,
      filter: TrendDateFilterEntity(
        start: DateTime(2026, 5, 2),
        end: DateTime(2026, 5, 4),
      ),
      transactions: <TransactionModel>[
        _transaction('p1', 9000, DateTime(2026, 4, 29, 8)),
        _transaction('c1', 10000, DateTime(2026, 5, 2, 9)),
        _transaction('c2', 12000, DateTime(2026, 5, 4, 10)),
      ],
      items: <TransactionItemModel>[
        _item('i1', 'p1', 'Tea', 'Minum', 2, 9000),
        _item('i2', 'c1', 'Coffee', 'Minum', 1, 10000),
        _item('i3', 'c2', 'Cake', 'Snack', 1, 12000),
      ],
      now: now,
    );

    expect(dashboard.dateFilter, isNotNull);
    expect(dashboard.revenueSeries, hasLength(3));
    expect(dashboard.kpi.totalSales, 22000);
    expect(dashboard.kpi.salesComparison.previousValue, 9000);
  });
}

TransactionModel _transaction(String id, int totalAmount, DateTime dateTime) {
  return TransactionModel(
    id: id,
    invoiceNumber: id,
    totalAmount: totalAmount,
    paidAmount: totalAmount,
    changeAmount: 0,
    totalItem: 1,
    createdAt: dateTime.millisecondsSinceEpoch,
  );
}

TransactionItemModel _item(
  String id,
  String transactionId,
  String productName,
  String categoryName,
  int quantity,
  int subtotal,
) {
  return TransactionItemModel(
    id: id,
    transactionId: transactionId,
    productId: productName,
    productName: productName,
    categoryName: categoryName,
    productPrice: subtotal,
    quantity: quantity,
    subtotal: subtotal,
    createdAt: DateTime(2026, 5, 6).millisecondsSinceEpoch,
  );
}
