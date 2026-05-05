import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lariss/core/errors/failure.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_breakdown_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_comparison_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_dashboard_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_date_filter_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_insight_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_kpi_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_movement_entity.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_range.dart';
import 'package:lariss/domain/trend_domain/domain/entities/trend_series_point_entity.dart';
import 'package:lariss/domain/trend_domain/domain/repositories/trend_repository.dart';
import 'package:lariss/domain/trend_domain/domain/usecases/get_trend_dashboard.dart';
import 'package:lariss/features/trend/presentation/cubit/trend_cubit.dart';
import 'package:lariss/features/trend/presentation/pages/trend_page.dart';

void main() {
  testWidgets('trend page load default harian dan pindah range', (
    WidgetTester tester,
  ) async {
    final _FakeTrendRepository repository = _FakeTrendRepository();
    final TrendCubit cubit = TrendCubit(
      getTrendDashboard: GetTrendDashboard(repository),
    );

    tester.view.physicalSize = const Size(1440, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TrendCubit>.value(
          value: cubit,
          child: const TrendPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.calls.first, TrendRange.daily);
    expect(find.text('Revenue trend'), findsOneWidget);
    expect(find.text('Transaction trend'), findsOneWidget);
    expect(find.text('Jam ramai'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
    expect(find.text('Insight cepat'), findsOneWidget);
    expect(find.text('AOV'), findsOneWidget);
    expect(find.text('Produk turun'), findsOneWidget);
    expect(find.text('Kategori turun'), findsOneWidget);

    await tester.tap(find.text('Mingguan'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(repository.calls.last, TrendRange.weekly);
    expect(find.text('Top kategori'), findsOneWidget);
  });
}

class _FakeTrendRepository implements TrendRepository {
  final List<TrendRange> calls = <TrendRange>[];

  @override
  Future<Either<Failure, TrendDashboardEntity>> getTrendDashboard(
    TrendRange range, {
    TrendDateFilterEntity? filter,
  }) async {
    calls.add(range);
    return right(_dashboard(range));
  }

  TrendDashboardEntity _dashboard(TrendRange range) {
    return TrendDashboardEntity(
      range: range,
      dateFilter: null,
      kpi: const TrendKpiEntity(
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
      revenueSeries: const <TrendSeriesPointEntity>[
        TrendSeriesPointEntity(
          label: 'A',
          shortLabel: 'A',
          totalSales: 10000,
          totalTransactions: 1,
        ),
        TrendSeriesPointEntity(
          label: 'B',
          shortLabel: 'B',
          totalSales: 45000,
          totalTransactions: 3,
        ),
      ],
      transactionSeries: const <TrendSeriesPointEntity>[
        TrendSeriesPointEntity(
          label: 'A',
          shortLabel: 'A',
          totalSales: 10000,
          totalTransactions: 1,
        ),
        TrendSeriesPointEntity(
          label: 'B',
          shortLabel: 'B',
          totalSales: 45000,
          totalTransactions: 3,
        ),
      ],
      busyHours: const <TrendBreakdownEntity>[
        TrendBreakdownEntity(
          label: '09:00',
          totalQuantity: 3,
          totalSales: 45000,
        ),
      ],
      topProducts: const <TrendBreakdownEntity>[
        TrendBreakdownEntity(
          label: 'Americano',
          totalQuantity: 4,
          totalSales: 55000,
        ),
      ],
      topCategories: const <TrendBreakdownEntity>[
        TrendBreakdownEntity(
          label: 'Kopi',
          totalQuantity: 4,
          totalSales: 55000,
        ),
      ],
      productDrops: const <TrendMovementEntity>[
        TrendMovementEntity(
          label: 'Latte',
          currentQuantity: 1,
          previousQuantity: 4,
          currentSales: 10000,
          previousSales: 40000,
        ),
      ],
      categoryDrops: const <TrendMovementEntity>[
        TrendMovementEntity(
          label: 'Tea',
          currentQuantity: 0,
          previousQuantity: 3,
          currentSales: 0,
          previousSales: 30000,
        ),
      ],
      insights: const <TrendInsightEntity>[
        TrendInsightEntity(
          title: 'Puncak sales',
          value: 'B',
          subtitle: 'Rp45.0rb dari 3 trx',
        ),
      ],
    );
  }
}
