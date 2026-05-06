import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_breakdown_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_comparison_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_dashboard_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_insight_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_kpi_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_movement_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_range.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_series_point_entity.dart';
import 'package:lariss/features/trend/presentation/services/trend_pdf_exporter.dart';

void main() {
  test('pdf exporter build bytes valid', () async {
    const TrendDashboardEntity dashboard = TrendDashboardEntity(
      range: TrendRange.weekly,
      dateFilter: null,
      kpi: TrendKpiEntity(
        totalSales: 55000,
        totalTransactions: 4,
        averageOrderValue: 13750,
        salesComparison: TrendComparisonEntity(
          currentValue: 55000,
          previousValue: 50000,
        ),
        transactionsComparison: TrendComparisonEntity(
          currentValue: 4,
          previousValue: 3,
        ),
      ),
      revenueSeries: <TrendSeriesPointEntity>[
        TrendSeriesPointEntity(
          label: 'A',
          shortLabel: 'A',
          startAt: 1,
          endAt: 2,
          totalSales: 10000,
          totalTransactions: 1,
        ),
      ],
      transactionSeries: <TrendSeriesPointEntity>[
        TrendSeriesPointEntity(
          label: 'A',
          shortLabel: 'A',
          startAt: 1,
          endAt: 2,
          totalSales: 10000,
          totalTransactions: 1,
        ),
      ],
      busyHours: <TrendBreakdownEntity>[
        TrendBreakdownEntity(label: '09:00', totalQuantity: 3, totalSales: 40000),
      ],
      topProducts: <TrendBreakdownEntity>[
        TrendBreakdownEntity(label: 'Americano', totalQuantity: 4, totalSales: 55000),
      ],
      topCategories: <TrendBreakdownEntity>[
        TrendBreakdownEntity(label: 'Kopi', totalQuantity: 4, totalSales: 55000),
      ],
      productDrops: <TrendMovementEntity>[
        TrendMovementEntity(
          label: 'Latte',
          currentQuantity: 1,
          previousQuantity: 4,
          currentSales: 10000,
          previousSales: 40000,
        ),
      ],
      categoryDrops: <TrendMovementEntity>[
        TrendMovementEntity(
          label: 'Tea',
          currentQuantity: 0,
          previousQuantity: 3,
          currentSales: 0,
          previousSales: 30000,
        ),
      ],
      insights: <TrendInsightEntity>[
        TrendInsightEntity(title: 'Jam ramai', value: '09:00', subtitle: '3 trx'),
      ],
    );

    final bytes = await const TrendPdfExporter().buildPdf(
      dashboard,
      generatedAt: DateTime(2026, 5, 6, 10, 30),
    );

    expect(bytes.length, greaterThan(100));
    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
  });
}
