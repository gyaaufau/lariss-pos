import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:lariss/core/errors/failure.dart';
import 'package:lariss/core/router/app_router.dart';
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
import 'package:lariss/features/trend/presentation/pages/trend_export_page.dart';
import 'package:lariss/features/trend/presentation/pages/trend_page.dart';
import 'package:lariss/features/trend/presentation/services/trend_csv_exporter.dart';
import 'package:lariss/features/trend/presentation/services/trend_export_file_handler.dart';

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

  testWidgets('trend page buka halaman export sendiri', (
    WidgetTester tester,
  ) async {
    final _FakeTrendRepository repository = _FakeTrendRepository();
    final TrendCubit cubit = TrendCubit(
      getTrendDashboard: GetTrendDashboard(repository),
    );

    final GoRouter router = GoRouter(
      initialLocation: AppRouter.trendPath,
      routes: <RouteBase>[
        GoRoute(
          path: AppRouter.trendPath,
          builder: (context, state) => BlocProvider<TrendCubit>.value(
            value: cubit,
            child: const TrendPage(),
          ),
          routes: <RouteBase>[
            GoRoute(
              path: 'export',
              builder: (context, state) => TrendExportPage(
                dashboard: state.extra as TrendDashboardEntity?,
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(find.text('Export trend'), findsOneWidget);
    expect(find.text('Harian'), findsOneWidget);
    expect(find.text('Bulanan'), findsOneWidget);
    expect(find.text('Export CSV'), findsOneWidget);
    expect(find.text('Export PDF'), findsOneWidget);
  });

  testWidgets('trend export tampilkan dialog lokasi file', (
    WidgetTester tester,
  ) async {
    final File file = File(
      '${Directory.systemTemp.path}/trend_test_export.csv',
    );
    if (!file.existsSync()) {
      file.writeAsStringSync('ok');
    }
    addTearDown(() async {
      if (file.existsSync()) {
        await file.delete();
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        home: TrendExportPage(
          dashboard: _FakeTrendRepository()._dashboard(TrendRange.daily),
          csvExporter: _FakeTrendCsvExporter(file),
          fileHandler: const _FakeTrendExportFileHandler(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Export CSV'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Export berhasil'), findsOneWidget);
    expect(find.text('CSV berhasil dibuat. File ada di:'), findsOneWidget);
    expect(find.text(file.path), findsOneWidget);
    expect(find.text('Buka file manager'), findsOneWidget);
    expect(find.text('Lihat file'), findsOneWidget);
    expect(find.text('Tutup'), findsWidgets);
  });

  testWidgets('trend export bisa ganti ke data bulanan', (
    WidgetTester tester,
  ) async {
    final _FakeTrendRepository repository = _FakeTrendRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: TrendExportPage(
          dashboard: repository._dashboard(TrendRange.daily),
          getTrendDashboard: GetTrendDashboard(repository),
          fileHandler: const _FakeTrendExportFileHandler(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bulanan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(repository.calls.last, TrendRange.monthly);
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
          startAt: 1,
          endAt: 2,
          totalSales: 10000,
          totalTransactions: 1,
        ),
        TrendSeriesPointEntity(
          label: 'B',
          shortLabel: 'B',
          startAt: 2,
          endAt: 3,
          totalSales: 45000,
          totalTransactions: 3,
        ),
      ],
      transactionSeries: const <TrendSeriesPointEntity>[
        TrendSeriesPointEntity(
          label: 'A',
          shortLabel: 'A',
          startAt: 1,
          endAt: 2,
          totalSales: 10000,
          totalTransactions: 1,
        ),
        TrendSeriesPointEntity(
          label: 'B',
          shortLabel: 'B',
          startAt: 2,
          endAt: 3,
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

class _FakeTrendCsvExporter extends TrendCsvExporter {
  const _FakeTrendCsvExporter(this.file);

  final File file;

  @override
  Future<File> export(TrendDashboardEntity dashboard) async => file;
}

class _FakeTrendExportFileHandler extends TrendExportFileHandler {
  const _FakeTrendExportFileHandler();

  @override
  Future<String?> openFile(File file) async => null;

  @override
  Future<String?> openFileManager(File file) async => null;
}
