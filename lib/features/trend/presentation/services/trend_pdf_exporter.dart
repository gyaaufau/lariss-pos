import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/utils/formatters.dart';
import '../../../../domain/trend_domain/domain/entities/trend_breakdown_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_dashboard_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_date_filter_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_insight_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_movement_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_series_point_entity.dart';
import 'trend_export_storage.dart';

class TrendPdfExporter {
  const TrendPdfExporter({this.storage = const TrendExportStorage()});

  final TrendExportStorage storage;

  Future<File> export(TrendDashboardEntity dashboard) async {
    final Directory exportDir = await storage.getExportDirectory();

    final DateTime now = DateTime.now();
    final String fileName =
        'trend_${dashboard.range.name}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.pdf';
    final File file = File(p.join(exportDir.path, fileName));
    await file.writeAsBytes(await buildPdf(dashboard, generatedAt: now));
    return file;
  }

  Future<Uint8List> buildPdf(
    TrendDashboardEntity dashboard, {
    DateTime? generatedAt,
  }) async {
    final DateTime timestamp = generatedAt ?? DateTime.now();
    final pw.Document doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        build: (pw.Context context) => <pw.Widget>[
          pw.Text(
            'Lariss Trend Export',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Generated at: ${_formatTimestamp(timestamp)}'),
          pw.Text('Range: ${dashboard.range.name}'),
          pw.Text(
            'Filter: ${dashboard.dateFilter == null ? '-' : _formatFilter(dashboard.dateFilter!)}',
          ),
          pw.SizedBox(height: 16),
          _section(
            'KPI',
            _table(
              const <String>['Metric', 'Value'],
              <List<String>>[
                <String>[
                  'Total sales',
                  formatCurrency(dashboard.kpi.totalSales),
                ],
                <String>[
                  'Transaksi',
                  dashboard.kpi.totalTransactions.toString(),
                ],
                <String>[
                  'AOV',
                  formatCurrency(dashboard.kpi.averageOrderValue),
                ],
                <String>[
                  'Sales compare',
                  '${dashboard.kpi.salesComparison.currentValue}/${dashboard.kpi.salesComparison.previousValue}',
                ],
                <String>[
                  'Transactions compare',
                  '${dashboard.kpi.transactionsComparison.currentValue}/${dashboard.kpi.transactionsComparison.previousValue}',
                ],
              ],
            ),
          ),
          _section('Revenue trend', _seriesTable(dashboard.revenueSeries)),
          _section(
            'Transaction trend',
            _seriesTable(dashboard.transactionSeries),
          ),
          _section('Jam ramai', _breakdownTable(dashboard.busyHours)),
          _section('Top product', _breakdownTable(dashboard.topProducts)),
          _section('Top kategori', _breakdownTable(dashboard.topCategories)),
          _section('Produk turun', _movementTable(dashboard.productDrops)),
          _section('Kategori turun', _movementTable(dashboard.categoryDrops)),
          _section('Insights', _insightTable(dashboard.insights)),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _section(String title, pw.Widget child) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  pw.Widget _seriesTable(List<TrendSeriesPointEntity> points) {
    return _table(
      const <String>['Label', 'Sales', 'Transactions', 'Start', 'End'],
      points
          .map(
            (TrendSeriesPointEntity point) => <String>[
              point.label,
              point.totalSales.toString(),
              point.totalTransactions.toString(),
              _formatEpoch(point.startAt),
              _formatEpoch(point.endAt),
            ],
          )
          .toList(growable: false),
    );
  }

  pw.Widget _breakdownTable(List<TrendBreakdownEntity> items) {
    return _table(
      const <String>['Label', 'Quantity', 'Sales'],
      items
          .map(
            (TrendBreakdownEntity item) => <String>[
              item.label,
              item.totalQuantity.toString(),
              item.totalSales.toString(),
            ],
          )
          .toList(growable: false),
    );
  }

  pw.Widget _movementTable(List<TrendMovementEntity> items) {
    return _table(
      const <String>[
        'Label',
        'Cur qty',
        'Prev qty',
        'Delta',
        'Cur sales',
        'Prev sales',
      ],
      items
          .map(
            (TrendMovementEntity item) => <String>[
              item.label,
              item.currentQuantity.toString(),
              item.previousQuantity.toString(),
              item.quantityDelta.toString(),
              item.currentSales.toString(),
              item.previousSales.toString(),
            ],
          )
          .toList(growable: false),
    );
  }

  pw.Widget _insightTable(List<TrendInsightEntity> items) {
    return _table(
      const <String>['Title', 'Value', 'Subtitle'],
      items
          .map(
            (TrendInsightEntity item) => <String>[
              item.title,
              item.value,
              item.subtitle,
            ],
          )
          .toList(growable: false),
    );
  }

  pw.Widget _table(List<String> headers, List<List<String>> rows) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows.isEmpty
          ? <List<String>>[List<String>.filled(headers.length, '-')]
          : rows,
      headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue100),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(6),
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    );
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
