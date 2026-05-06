import '../../domain/entities/trend_comparison_entity.dart';
import '../../domain/entities/trend_date_filter_entity.dart';
import '../../domain/entities/trend_range.dart';
import '../../../../core/utils/formatters.dart';
import '../models/trend_breakdown_model.dart';
import '../models/trend_dashboard_model.dart';
import '../models/trend_insight_model.dart';
import '../models/trend_kpi_model.dart';
import '../models/trend_movement_model.dart';
import '../models/trend_series_point_model.dart';
import '../../../transaction_domain/domain/entities/transaction_entity.dart';
import '../../../transaction_domain/domain/entities/transaction_item_entity.dart';

class TrendDashboardAggregator {
  TrendDashboardModel build({
    required TrendRange range,
    TrendDateFilterEntity? filter,
    required List<TransactionEntity> transactions,
    required List<TransactionItemEntity> items,
    required DateTime now,
  }) {
    final DateTime reference = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    );
    final TrendDateFilterEntity? normalizedFilter = _normalizeFilter(
      range,
      filter,
    );
    final List<_Bucket> buckets = _createBuckets(
      range,
      reference,
      filter: normalizedFilter,
    );
    final Map<String, _Bucket> bucketsByKey = <String, _Bucket>{
      for (final _Bucket bucket in buckets) bucket.key: bucket,
    };
    final _PeriodWindow currentWindow = _currentWindow(
      range,
      reference,
      filter: normalizedFilter,
    );
    final _PeriodWindow previousWindow = _previousWindow(range, currentWindow);
    final Set<String> activeTransactionIds = <String>{};
    int totalSales = 0;
    int totalTransactions = 0;
    int previousSales = 0;
    int previousTransactions = 0;

    for (final TransactionEntity transaction in transactions) {
      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
        transaction.createdAt,
      );
      if (_isInWindow(timestamp, previousWindow)) {
        previousSales += transaction.totalAmount;
        previousTransactions += 1;
      }
      final String? bucketKey = _resolveBucketKey(
        range: range,
        timestamp: timestamp,
        now: reference,
        buckets: buckets,
      );
      if (bucketKey == null) {
        continue;
      }

      final _Bucket bucket = bucketsByKey[bucketKey]!;
      bucket.totalSales += transaction.totalAmount;
      bucket.totalTransactions += 1;
      totalSales += transaction.totalAmount;
      totalTransactions += 1;
      activeTransactionIds.add(transaction.id);
    }

    final Map<String, _BreakdownAccumulator> productMap =
        <String, _BreakdownAccumulator>{};
    final Map<String, _BreakdownAccumulator> categoryMap =
        <String, _BreakdownAccumulator>{};
    final Map<String, _BreakdownAccumulator> previousProductMap =
        <String, _BreakdownAccumulator>{};
    final Map<String, _BreakdownAccumulator> previousCategoryMap =
        <String, _BreakdownAccumulator>{};
    final Map<String, _BreakdownAccumulator> busyHourMap =
        <String, _BreakdownAccumulator>{};
    final Set<String> previousTransactionIds = <String>{};

    for (final TransactionEntity transaction in transactions) {
      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
        transaction.createdAt,
      );
      if (_isInWindow(timestamp, previousWindow)) {
        previousTransactionIds.add(transaction.id);
      }
    }

    for (final TransactionItemEntity item in items) {
      if (activeTransactionIds.contains(item.transactionId)) {
        final _BreakdownAccumulator product = productMap.putIfAbsent(
          item.productName,
          () => _BreakdownAccumulator(item.productName),
        );
        product.totalQuantity += item.quantity;
        product.totalSales += item.subtotal;

        final _BreakdownAccumulator category = categoryMap.putIfAbsent(
          item.categoryName,
          () => _BreakdownAccumulator(item.categoryName),
        );
        category.totalQuantity += item.quantity;
        category.totalSales += item.subtotal;
      }

      if (previousTransactionIds.contains(item.transactionId)) {
        final _BreakdownAccumulator product = previousProductMap.putIfAbsent(
          item.productName,
          () => _BreakdownAccumulator(item.productName),
        );
        product.totalQuantity += item.quantity;
        product.totalSales += item.subtotal;

        final _BreakdownAccumulator category = previousCategoryMap.putIfAbsent(
          item.categoryName,
          () => _BreakdownAccumulator(item.categoryName),
        );
        category.totalQuantity += item.quantity;
        category.totalSales += item.subtotal;
      }
    }

    for (final TransactionEntity transaction in transactions) {
      if (!activeTransactionIds.contains(transaction.id)) {
        continue;
      }
      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
        transaction.createdAt,
      );
      final String label = '${timestamp.hour.toString().padLeft(2, '0')}:00';
      final _BreakdownAccumulator bucket = busyHourMap.putIfAbsent(
        label,
        () => _BreakdownAccumulator(label),
      );
      bucket.totalQuantity += 1;
      bucket.totalSales += transaction.totalAmount;
    }

    final List<TrendSeriesPointModel> revenueSeries = buckets
        .map(
          (_Bucket bucket) => TrendSeriesPointModel(
            label: bucket.label,
            shortLabel: bucket.shortLabel,
            startAt: bucket.start.millisecondsSinceEpoch,
            endAt: bucket.end.millisecondsSinceEpoch,
            totalSales: bucket.totalSales,
            totalTransactions: bucket.totalTransactions,
          ),
        )
        .toList(growable: false);

    final List<TrendSeriesPointModel> transactionSeries = buckets
        .map(
          (_Bucket bucket) => TrendSeriesPointModel(
            label: bucket.label,
            shortLabel: bucket.shortLabel,
            startAt: bucket.start.millisecondsSinceEpoch,
            endAt: bucket.end.millisecondsSinceEpoch,
            totalSales: bucket.totalSales,
            totalTransactions: bucket.totalTransactions,
          ),
        )
        .toList(growable: false);

    final List<TrendBreakdownModel> topProducts = _topBreakdowns(productMap);
    final List<TrendBreakdownModel> topCategories = _topBreakdowns(categoryMap);
    final List<TrendBreakdownModel> busyHours = _topBreakdowns(
      busyHourMap,
      limit: 6,
    );
    final List<TrendMovementModel> productDrops = _buildDrops(
      current: productMap,
      previous: previousProductMap,
    );
    final List<TrendMovementModel> categoryDrops = _buildDrops(
      current: categoryMap,
      previous: previousCategoryMap,
    );

    return TrendDashboardModel(
      range: range,
      dateFilter: normalizedFilter,
      kpi: TrendKpiModel(
        totalSales: totalSales,
        totalTransactions: totalTransactions,
        averageOrderValue: totalTransactions == 0 ? 0 : totalSales ~/ totalTransactions,
        salesComparison: TrendComparisonEntity(
          currentValue: totalSales,
          previousValue: previousSales,
        ),
        transactionsComparison: TrendComparisonEntity(
          currentValue: totalTransactions,
          previousValue: previousTransactions,
        ),
      ),
      revenueSeries: revenueSeries,
      transactionSeries: transactionSeries,
      busyHours: busyHours,
      topProducts: topProducts,
      topCategories: topCategories,
      productDrops: productDrops,
      categoryDrops: categoryDrops,
      insights: _buildInsights(
        revenueSeries: revenueSeries,
        busyHours: busyHours,
        topProducts: topProducts,
        topCategories: topCategories,
        productDrops: productDrops,
        categoryDrops: categoryDrops,
      ),
    );
  }

  List<TrendInsightModel> _buildInsights({
    required List<TrendSeriesPointModel> revenueSeries,
    required List<TrendBreakdownModel> busyHours,
    required List<TrendBreakdownModel> topProducts,
    required List<TrendBreakdownModel> topCategories,
    required List<TrendMovementModel> productDrops,
    required List<TrendMovementModel> categoryDrops,
  }) {
    final TrendSeriesPointModel? bestBucket = revenueSeries.isEmpty
        ? null
        : revenueSeries.reduce(
            (TrendSeriesPointModel a, TrendSeriesPointModel b) =>
                b.totalSales > a.totalSales ? b : a,
          );
    final List<TrendInsightModel> insights = <TrendInsightModel>[];

    if (bestBucket != null && bestBucket.totalSales > 0) {
      insights.add(
        TrendInsightModel(
          title: 'Puncak sales',
          value: bestBucket.label,
          subtitle:
              '${formatCompactCurrency(bestBucket.totalSales)} dari ${bestBucket.totalTransactions} trx',
        ),
      );
    }
    if (busyHours.isNotEmpty) {
      final TrendBreakdownModel peakHour = busyHours.first;
      insights.add(
        TrendInsightModel(
          title: 'Jam ramai',
          value: peakHour.label,
          subtitle:
              '${peakHour.totalQuantity} trx • ${formatCompactCurrency(peakHour.totalSales)}',
        ),
      );
    }
    if (topProducts.isNotEmpty) {
      final TrendBreakdownModel topProduct = topProducts.first;
      insights.add(
        TrendInsightModel(
          title: 'Produk terlaris',
          value: topProduct.label,
          subtitle:
              '${topProduct.totalQuantity} item • ${formatCompactCurrency(topProduct.totalSales)}',
        ),
      );
    }
    if (topCategories.isNotEmpty) {
      final TrendBreakdownModel topCategory = topCategories.first;
      insights.add(
        TrendInsightModel(
          title: 'Kategori terkuat',
          value: topCategory.label,
          subtitle:
              '${topCategory.totalQuantity} item • ${formatCompactCurrency(topCategory.totalSales)}',
        ),
      );
    }
    if (productDrops.isNotEmpty) {
      final TrendMovementModel drop = productDrops.first;
      insights.add(
        TrendInsightModel(
          title: 'Produk turun',
          value: drop.label,
          subtitle:
              '${drop.previousQuantity} -> ${drop.currentQuantity} item (${drop.quantityDelta})',
        ),
      );
    }
    if (categoryDrops.isNotEmpty) {
      final TrendMovementModel drop = categoryDrops.first;
      insights.add(
        TrendInsightModel(
          title: 'Kategori turun',
          value: drop.label,
          subtitle:
              '${drop.previousQuantity} -> ${drop.currentQuantity} item (${drop.quantityDelta})',
        ),
      );
    }

    return insights;
  }

  List<TrendMovementModel> _buildDrops({
    required Map<String, _BreakdownAccumulator> current,
    required Map<String, _BreakdownAccumulator> previous,
  }) {
    final Set<String> labels = <String>{
      ...current.keys,
      ...previous.keys,
    };
    final List<TrendMovementModel> items = labels.map((String label) {
      final _BreakdownAccumulator? currentItem = current[label];
      final _BreakdownAccumulator? previousItem = previous[label];
      return TrendMovementModel(
        label: label,
        currentQuantity: currentItem?.totalQuantity ?? 0,
        previousQuantity: previousItem?.totalQuantity ?? 0,
        currentSales: currentItem?.totalSales ?? 0,
        previousSales: previousItem?.totalSales ?? 0,
      );
    }).where((TrendMovementModel item) {
      return item.previousQuantity > item.currentQuantity;
    }).toList()
      ..sort((TrendMovementModel a, TrendMovementModel b) {
        final int byDelta = a.quantityDelta.compareTo(b.quantityDelta);
        if (byDelta != 0) {
          return byDelta;
        }
        return a.salesDelta.compareTo(b.salesDelta);
      });

    return items.take(3).toList(growable: false);
  }

  List<TrendBreakdownModel> _topBreakdowns(
    Map<String, _BreakdownAccumulator> source, {
    int limit = 5,
  }) {
    final List<_BreakdownAccumulator> items = source.values.toList()
      ..sort(
        (_BreakdownAccumulator a, _BreakdownAccumulator b) =>
            b.totalQuantity.compareTo(a.totalQuantity) !=
                0
            ? b.totalQuantity.compareTo(a.totalQuantity)
            : b.totalSales.compareTo(a.totalSales),
      );

    return items
        .take(limit)
        .map(
          (_BreakdownAccumulator item) => TrendBreakdownModel(
            label: item.label,
            totalQuantity: item.totalQuantity,
            totalSales: item.totalSales,
          ),
        )
        .toList(growable: false);
  }

  List<_Bucket> _createBuckets(
    TrendRange range,
    DateTime now, {
    TrendDateFilterEntity? filter,
  }) {
    switch (range) {
      case TrendRange.daily:
        final DateTime day = DateTime(now.year, now.month, now.day);
        return List<_Bucket>.generate(24, (int hour) {
          return _Bucket(
            key: '$hour',
            label: '${hour.toString().padLeft(2, '0')}:00',
            shortLabel: hour.toString().padLeft(2, '0'),
            start: day.add(Duration(hours: hour)),
            end: day.add(Duration(hours: hour + 1)),
          );
        }, growable: false);
      case TrendRange.weekly:
        final DateTime today = DateTime(now.year, now.month, now.day);
        return List<_Bucket>.generate(7, (int index) {
          final DateTime start = today.subtract(Duration(days: 6 - index));
          return _Bucket(
            key: _dayKey(start),
            label: _formatDayMonth(start),
            shortLabel: _weekdayShort(start.weekday),
            start: start,
            end: start.add(const Duration(days: 1)),
          );
        }, growable: false);
      case TrendRange.monthly:
        final DateTime end = DateTime(now.year, now.month, now.day)
            .add(const Duration(days: 1));
        final DateTime start = end.subtract(const Duration(days: 30));
        final List<_Bucket> buckets = <_Bucket>[];
        DateTime cursor = start;
        while (cursor.isBefore(end)) {
          final DateTime bucketEnd = cursor.add(const Duration(days: 7));
          final DateTime safeEnd = bucketEnd.isAfter(end) ? end : bucketEnd;
          buckets.add(
            _Bucket(
              key: _dayKey(cursor),
              label:
                  '${_formatDayMonth(cursor)} - ${_formatDayMonth(safeEnd.subtract(const Duration(days: 1)))}',
              shortLabel: '${cursor.day}/${cursor.month}',
              start: cursor,
              end: safeEnd,
            ),
          );
          cursor = safeEnd;
        }
        return buckets;
      case TrendRange.yearly:
        final DateTime monthStart = DateTime(now.year, now.month);
        return List<_Bucket>.generate(12, (int index) {
          final DateTime start = DateTime(
            monthStart.year,
            monthStart.month - 11 + index,
          );
          final DateTime end = DateTime(start.year, start.month + 1);
          return _Bucket(
            key: '${start.year}-${start.month}',
            label: _monthYearLabel(start),
            shortLabel: _monthShort(start.month),
            start: start,
            end: end,
          );
        }, growable: false);
      case TrendRange.custom:
        if (filter == null) {
          return const <_Bucket>[];
        }
        final List<_Bucket> buckets = <_Bucket>[];
        DateTime cursor = DateTime(
          filter.start.year,
          filter.start.month,
          filter.start.day,
        );
        final DateTime endExclusive = DateTime(
          filter.end.year,
          filter.end.month,
          filter.end.day + 1,
        );
        while (cursor.isBefore(endExclusive)) {
          final DateTime next = cursor.add(const Duration(days: 1));
          buckets.add(
            _Bucket(
              key: _dayKey(cursor),
              label: _formatDayMonth(cursor),
              shortLabel: '${cursor.day}/${cursor.month}',
              start: cursor,
              end: next,
            ),
          );
          cursor = next;
        }
        return buckets;
    }
  }

  String? _resolveBucketKey({
    required TrendRange range,
    required DateTime timestamp,
    required DateTime now,
    required List<_Bucket> buckets,
  }) {
    switch (range) {
      case TrendRange.daily:
        if (timestamp.year != now.year ||
            timestamp.month != now.month ||
            timestamp.day != now.day) {
          return null;
        }
        return '${timestamp.hour}';
      case TrendRange.weekly:
        final DateTime day = DateTime(
          timestamp.year,
          timestamp.month,
          timestamp.day,
        );
        final DateTime start = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6));
        final DateTime end = DateTime(now.year, now.month, now.day + 1);
        if (day.isBefore(start) || !day.isBefore(end)) {
          return null;
        }
        return _dayKey(day);
      case TrendRange.monthly:
      case TrendRange.yearly:
      case TrendRange.custom:
        for (final _Bucket bucket in buckets) {
          if (!timestamp.isBefore(bucket.start) && timestamp.isBefore(bucket.end)) {
            return bucket.key;
          }
        }
        return null;
    }
  }

  String _dayKey(DateTime value) => '${value.year}-${value.month}-${value.day}';

  String _formatDayMonth(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
  }

  String _monthYearLabel(DateTime value) {
    return '${_monthShort(value.month)} ${value.year}';
  }

  String _monthShort(int month) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  String _weekdayShort(int weekday) {
    const List<String> days = <String>[
      'Sen',
      'Sel',
      'Rab',
      'Kam',
      'Jum',
      'Sab',
      'Min',
    ];
    return days[weekday - 1];
  }

  _PeriodWindow _currentWindow(
    TrendRange range,
    DateTime now, {
    TrendDateFilterEntity? filter,
  }) {
    switch (range) {
      case TrendRange.daily:
        final DateTime start = DateTime(now.year, now.month, now.day);
        return _PeriodWindow(start: start, end: start.add(const Duration(days: 1)));
      case TrendRange.weekly:
        final DateTime end = DateTime(now.year, now.month, now.day + 1);
        return _PeriodWindow(start: end.subtract(const Duration(days: 7)), end: end);
      case TrendRange.monthly:
        final DateTime end = DateTime(now.year, now.month, now.day + 1);
        return _PeriodWindow(start: end.subtract(const Duration(days: 30)), end: end);
      case TrendRange.yearly:
        final DateTime end = DateTime(now.year, now.month + 1);
        return _PeriodWindow(start: DateTime(end.year, end.month - 12), end: end);
      case TrendRange.custom:
        if (filter == null) {
          return _PeriodWindow(start: now, end: now);
        }
        return _PeriodWindow(
          start: DateTime(filter.start.year, filter.start.month, filter.start.day),
          end: DateTime(filter.end.year, filter.end.month, filter.end.day + 1),
        );
    }
  }

  _PeriodWindow _previousWindow(TrendRange range, _PeriodWindow current) {
    switch (range) {
      case TrendRange.daily:
        return _PeriodWindow(
          start: current.start.subtract(const Duration(days: 1)),
          end: current.start,
        );
      case TrendRange.weekly:
        return _PeriodWindow(
          start: current.start.subtract(const Duration(days: 7)),
          end: current.start,
        );
      case TrendRange.monthly:
        return _PeriodWindow(
          start: current.start.subtract(const Duration(days: 30)),
          end: current.start,
        );
      case TrendRange.yearly:
        return _PeriodWindow(
          start: DateTime(current.start.year - 1, current.start.month),
          end: current.start,
        );
      case TrendRange.custom:
        final Duration span = current.end.difference(current.start);
        return _PeriodWindow(
          start: current.start.subtract(span),
          end: current.start,
        );
    }
  }

  bool _isInWindow(DateTime value, _PeriodWindow window) {
    return !value.isBefore(window.start) && value.isBefore(window.end);
  }

  TrendDateFilterEntity? _normalizeFilter(
    TrendRange range,
    TrendDateFilterEntity? filter,
  ) {
    if (range != TrendRange.custom || filter == null) {
      return null;
    }

    final DateTime start = DateTime(
      filter.start.year,
      filter.start.month,
      filter.start.day,
    );
    final DateTime end = DateTime(
      filter.end.year,
      filter.end.month,
      filter.end.day,
    );
    if (end.isBefore(start)) {
      return TrendDateFilterEntity(start: end, end: start);
    }
    return TrendDateFilterEntity(start: start, end: end);
  }
}

class _Bucket {
  _Bucket({
    required this.key,
    required this.label,
    required this.shortLabel,
    required this.start,
    required this.end,
  });

  final String key;
  final String label;
  final String shortLabel;
  final DateTime start;
  final DateTime end;
  int totalSales = 0;
  int totalTransactions = 0;
}

class _BreakdownAccumulator {
  _BreakdownAccumulator(this.label);

  final String label;
  int totalQuantity = 0;
  int totalSales = 0;
}

class _PeriodWindow {
  const _PeriodWindow({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;
}
