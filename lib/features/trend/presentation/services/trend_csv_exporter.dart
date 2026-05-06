import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../../core/utils/formatters.dart';
import '../../../../domain/trend_domain/domain/entities/trend_breakdown_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_dashboard_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_date_filter_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_insight_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_movement_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_series_point_entity.dart';
import 'trend_export_storage.dart';

class TrendCsvExporter {
  const TrendCsvExporter({this.storage = const TrendExportStorage()});

  final TrendExportStorage storage;

  Future<File> export(TrendDashboardEntity dashboard) async {
    final Directory exportDir = await storage.getExportDirectory();

    final DateTime now = DateTime.now();
    final String fileName =
        'trend_${dashboard.range.name}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.csv';
    final File file = File(p.join(exportDir.path, fileName));
    await file.writeAsString(buildCsv(dashboard, generatedAt: now));
    return file;
  }

  String buildCsv(TrendDashboardEntity dashboard, {DateTime? generatedAt}) {
    final DateTime timestamp = generatedAt ?? DateTime.now();
    final List<List<String>> rows = <List<String>>[
      <String>['Lariss Trend Export'],
      <String>['Generated at', _formatTimestamp(timestamp)],
      <String>['Range', dashboard.range.name],
      <String>[
        'Filter',
        dashboard.dateFilter == null
            ? '-'
            : _formatFilter(dashboard.dateFilter!),
      ],
      const <String>[],
      <String>['KPI'],
      <String>['Metric', 'Value'],
      <String>['Total sales', formatCurrency(dashboard.kpi.totalSales)],
      <String>['Transaksi', dashboard.kpi.totalTransactions.toString()],
      <String>['AOV', formatCurrency(dashboard.kpi.averageOrderValue)],
      <String>[
        'Sales compare',
        '${dashboard.kpi.salesComparison.currentValue}/${dashboard.kpi.salesComparison.previousValue}',
      ],
      <String>[
        'Transactions compare',
        '${dashboard.kpi.transactionsComparison.currentValue}/${dashboard.kpi.transactionsComparison.previousValue}',
      ],
      const <String>[],
    ];

    _appendSeries(rows, 'Revenue trend', dashboard.revenueSeries);
    _appendSeries(rows, 'Transaction trend', dashboard.transactionSeries);
    _appendBreakdowns(rows, 'Jam ramai', dashboard.busyHours);
    _appendBreakdowns(rows, 'Top product', dashboard.topProducts);
    _appendBreakdowns(rows, 'Top kategori', dashboard.topCategories);
    _appendMovements(rows, 'Produk turun', dashboard.productDrops);
    _appendMovements(rows, 'Kategori turun', dashboard.categoryDrops);
    _appendInsights(rows, dashboard.insights);

    return rows.map(_toCsvLine).join('\n');
  }

  void _appendSeries(
    List<List<String>> rows,
    String title,
    List<TrendSeriesPointEntity> points,
  ) {
    rows.add(<String>[title]);
    rows.add(<String>['Label', 'Sales', 'Transactions', 'Start', 'End']);
    for (final TrendSeriesPointEntity point in points) {
      rows.add(<String>[
        point.label,
        point.totalSales.toString(),
        point.totalTransactions.toString(),
        _formatEpoch(point.startAt),
        _formatEpoch(point.endAt),
      ]);
    }
    rows.add(const <String>[]);
  }

  void _appendBreakdowns(
    List<List<String>> rows,
    String title,
    List<TrendBreakdownEntity> items,
  ) {
    rows.add(<String>[title]);
    rows.add(<String>['Label', 'Quantity', 'Sales']);
    for (final TrendBreakdownEntity item in items) {
      rows.add(<String>[
        item.label,
        item.totalQuantity.toString(),
        item.totalSales.toString(),
      ]);
    }
    rows.add(const <String>[]);
  }

  void _appendMovements(
    List<List<String>> rows,
    String title,
    List<TrendMovementEntity> items,
  ) {
    rows.add(<String>[title]);
    rows.add(<String>[
      'Label',
      'Current qty',
      'Previous qty',
      'Qty delta',
      'Current sales',
      'Previous sales',
      'Sales delta',
    ]);
    for (final TrendMovementEntity item in items) {
      rows.add(<String>[
        item.label,
        item.currentQuantity.toString(),
        item.previousQuantity.toString(),
        item.quantityDelta.toString(),
        item.currentSales.toString(),
        item.previousSales.toString(),
        item.salesDelta.toString(),
      ]);
    }
    rows.add(const <String>[]);
  }

  void _appendInsights(
    List<List<String>> rows,
    List<TrendInsightEntity> insights,
  ) {
    rows.add(<String>['Insights']);
    rows.add(<String>['Title', 'Value', 'Subtitle']);
    for (final TrendInsightEntity insight in insights) {
      rows.add(<String>[insight.title, insight.value, insight.subtitle]);
    }
  }

  String _toCsvLine(List<String> values) {
    return values.map(_escape).join(',');
  }

  String _escape(String value) {
    final String escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _formatEpoch(int epochMs) {
    return _formatTimestamp(DateTime.fromMillisecondsSinceEpoch(epochMs));
  }

  String _formatTimestamp(DateTime value) {
    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String year = value.year.toString();
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _formatFilter(TrendDateFilterEntity filter) {
    return '${filter.start.day}/${filter.start.month}/${filter.start.year} - ${filter.end.day}/${filter.end.month}/${filter.end.year}';
  }
}
