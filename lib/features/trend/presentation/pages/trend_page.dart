import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/transaction_domain/domain/entities/transaction_entity.dart';
import '../../../../domain/transaction_domain/domain/usecases/get_transaction_history.dart';
import '../../../../domain/trend_domain/domain/entities/trend_breakdown_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_comparison_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_date_filter_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_dashboard_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_insight_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_movement_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_range.dart';
import '../../../../domain/trend_domain/domain/entities/trend_series_point_entity.dart';
import '../cubit/trend_cubit.dart';
import '../cubit/trend_state.dart';

class TrendPage extends StatefulWidget {
  const TrendPage({super.key});

  @override
  State<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrendCubit>().loadTrend();
    });
  }

  @override
  Widget build(BuildContext context) {
    final TrendDashboardEntity? dashboard = context.select(
      (TrendCubit cubit) => cubit.state.dashboard,
    );
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trend penjualan'),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: TextButton.icon(
              onPressed: dashboard == null
                  ? null
                  : () => context.push(
                      AppRouter.trendExportPath,
                      extra: dashboard,
                    ),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Export'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onPrimary,
                backgroundColor: colorScheme.primary,
                disabledForegroundColor: const Color(0xFF94A3B8),
                disabledBackgroundColor: const Color(0xFFF1F5F9),
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<TrendCubit, TrendState>(
        listener: (BuildContext context, TrendState state) {
          if (state.status == TrendStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (BuildContext context, TrendState state) {
          final TrendDashboardEntity? dashboard = state.dashboard;
          final bool isInitialLoading =
              state.status == TrendStatus.loading && dashboard == null;

          return SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0.h),
                  child: _TrendRangeTabs(
                    selectedRange: state.selectedRange,
                    selectedFilter: state.selectedFilter,
                    onChanged: (TrendRange range) {
                      context.read<TrendCubit>().loadTrend(range: range);
                    },
                    onCustomTap: () => _pickCustomRange(context, state),
                  ),
                ),
                if (state.isRefreshing) const LinearProgressIndicator(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: isInitialLoading
                        ? const _TrendLoadingState()
                        : dashboard == null || !dashboard.hasActivity
                        ? _EmptyTrendState(range: state.selectedRange)
                        : RefreshIndicator(
                            onRefresh: () =>
                                context.read<TrendCubit>().loadTrend(
                                  range: state.selectedRange,
                                  forceRefresh: true,
                                ),
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: _KpiCard(
                                        title: 'Total sales',
                                        value: formatCurrency(
                                          dashboard.kpi.totalSales,
                                        ),
                                        comparison:
                                            dashboard.kpi.salesComparison,
                                        color: const Color(0xFF2563EB),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: _KpiCard(
                                        title: 'Transaksi',
                                        value: formatNumber(
                                          dashboard.kpi.totalTransactions,
                                        ),
                                        comparison: dashboard
                                            .kpi
                                            .transactionsComparison,
                                        color: const Color(0xFF16A34A),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                _ChartPanel(
                                  title: 'Insight cepat',
                                  subtitle: 'Ringkas performa range aktif',
                                  child: Column(
                                    children: <Widget>[
                                      _InsightCard(
                                        title: 'AOV',
                                        value: formatCurrency(
                                          dashboard.kpi.averageOrderValue,
                                        ),
                                        subtitle: 'Rata-rata nilai transaksi',
                                      ),
                                      if (dashboard.insights.isNotEmpty)
                                        ...dashboard.insights.map(
                                          (TrendInsightEntity insight) =>
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: 12,
                                                ),
                                                child: _InsightCard(
                                                  title: insight.title,
                                                  value: insight.value,
                                                  subtitle: insight.subtitle,
                                                ),
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                _ChartPanel(
                                  title: 'Revenue trend',
                                  subtitle: _rangeDescription(
                                    dashboard.range,
                                    filter: dashboard.dateFilter,
                                  ),
                                  child: _LineTrendChart(
                                    points: dashboard.revenueSeries,
                                    color: const Color(0xFF2563EB),
                                    onPointTap:
                                        (TrendSeriesPointEntity point) =>
                                            _openBucketTransactions(
                                              context,
                                              title: 'Revenue ${point.label}',
                                              predicate:
                                                  (TransactionEntity tx) =>
                                                      _inPointWindow(tx, point),
                                            ),
                                    valueSelector:
                                        (TrendSeriesPointEntity point) =>
                                            point.totalSales,
                                    tooltipFormatter:
                                        (TrendSeriesPointEntity point) =>
                                            '${point.label}\n${formatCurrency(point.totalSales)}',
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                _ChartPanel(
                                  title: 'Transaction trend',
                                  subtitle: 'Volume transaksi per bucket waktu',
                                  child: _LineTrendChart(
                                    points: dashboard.transactionSeries,
                                    color: const Color(0xFF16A34A),
                                    onPointTap:
                                        (TrendSeriesPointEntity point) =>
                                            _openBucketTransactions(
                                              context,
                                              title: 'Transaksi ${point.label}',
                                              predicate:
                                                  (TransactionEntity tx) =>
                                                      _inPointWindow(tx, point),
                                            ),
                                    valueSelector:
                                        (TrendSeriesPointEntity point) =>
                                            point.totalTransactions,
                                    tooltipFormatter:
                                        (TrendSeriesPointEntity point) =>
                                            '${point.label}\n${point.totalTransactions} trx',
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                _ChartPanel(
                                  title: 'Jam ramai',
                                  subtitle:
                                      'Top jam dengan transaksi tertinggi',
                                  child: _BreakdownBarChart(
                                    items: dashboard.busyHours,
                                    color: const Color(0xFFEF4444),
                                    onBarTap: (TrendBreakdownEntity item) =>
                                        _openBucketTransactions(
                                          context,
                                          title: 'Jam ramai ${item.label}',
                                          predicate: (TransactionEntity tx) =>
                                              _sameHourInDashboard(
                                                tx.createdAt,
                                                item.label,
                                                dashboard.transactionSeries,
                                              ),
                                        ),
                                    metricLabelBuilder:
                                        (TrendBreakdownEntity item) =>
                                            '${item.totalQuantity} trx',
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                _ChartPanel(
                                  title: 'Top product',
                                  subtitle: 'Top 5 produk by qty',
                                  child: _BreakdownBarChart(
                                    items: dashboard.topProducts,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                _ChartPanel(
                                  title: 'Top kategori',
                                  subtitle: 'Top 5 kategori by qty',
                                  child: _BreakdownBarChart(
                                    items: dashboard.topCategories,
                                    color: const Color(0xFF8B5CF6),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                _ChartPanel(
                                  title: 'Produk turun',
                                  subtitle:
                                      'Produk yang melemah vs periode lalu',
                                  child: _MovementList(
                                    items: dashboard.productDrops,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                _ChartPanel(
                                  title: 'Kategori turun',
                                  subtitle:
                                      'Kategori yang melemah vs periode lalu',
                                  child: _MovementList(
                                    items: dashboard.categoryDrops,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickCustomRange(BuildContext context, TrendState state) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: state.selectedFilter == null
          ? null
          : DateTimeRange(
              start: state.selectedFilter!.start,
              end: state.selectedFilter!.end,
            ),
    );
    if (!context.mounted || picked == null) {
      return;
    }

    context.read<TrendCubit>().loadTrend(
      range: TrendRange.custom,
      filter: TrendDateFilterEntity(start: picked.start, end: picked.end),
    );
  }

  bool _inPointWindow(TransactionEntity tx, TrendSeriesPointEntity point) {
    return tx.createdAt >= point.startAt && tx.createdAt < point.endAt;
  }

  bool _sameHourInDashboard(
    int epochMs,
    String hourLabel,
    List<TrendSeriesPointEntity> points,
  ) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final String label = '${date.hour.toString().padLeft(2, '0')}:00';
    if (label != hourLabel) {
      return false;
    }
    if (points.isEmpty) {
      return false;
    }
    return epochMs >= points.first.startAt && epochMs < points.last.endAt;
  }

  Future<void> _openBucketTransactions(
    BuildContext context, {
    required String title,
    required bool Function(TransactionEntity tx) predicate,
  }) async {
    final result = await sl<GetTransactionHistory>()();
    if (!context.mounted) {
      return;
    }

    result.match(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (transactions) async {
        final List<TransactionEntity> filtered = transactions
            .where(predicate)
            .toList(growable: false);

        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) =>
              _BucketTransactionSheet(title: title, transactions: filtered),
        );
      },
    );
  }
}

class _TrendRangeTabs extends StatelessWidget {
  const _TrendRangeTabs({
    required this.selectedRange,
    required this.selectedFilter,
    required this.onChanged,
    required this.onCustomTap,
  });

  final TrendRange selectedRange;
  final TrendDateFilterEntity? selectedFilter;
  final ValueChanged<TrendRange> onChanged;
  final VoidCallback onCustomTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          ...<TrendRange>[
            TrendRange.daily,
            TrendRange.weekly,
            TrendRange.monthly,
            TrendRange.yearly,
          ].map((TrendRange range) {
            final bool isSelected = range == selectedRange;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: ChoiceChip(
                label: Text(_rangeLabel(range)),
                selected: isSelected,
                onSelected: (_) => onChanged(range),
              ),
            );
          }),
          ChoiceChip(
            label: Text(
              selectedRange == TrendRange.custom && selectedFilter != null
                  ? _filterLabel(selectedFilter!)
                  : 'Custom',
            ),
            selected: selectedRange == TrendRange.custom,
            onSelected: (_) => onCustomTap(),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.comparison,
    required this.color,
  });

  final String title;
  final String value;
  final TrendComparisonEntity comparison;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool showComparison = comparison.previousValue > 0;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 8.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (showComparison) ...<Widget>[
            SizedBox(height: 10.h),
            _ComparisonBadge(comparison: comparison),
          ],
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 6.h),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4.h),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ComparisonBadge extends StatelessWidget {
  const _ComparisonBadge({required this.comparison});

  final TrendComparisonEntity comparison;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;

    if (comparison.previousValue == 0 && comparison.currentValue > 0) {
      label = 'Baru naik';
      color = const Color(0xFF2563EB);
    } else if (comparison.changePercent == 0) {
      label = 'Stabil';
      color = const Color(0xFF64748B);
    } else if (comparison.isUp) {
      label = '+${comparison.changePercent!.toStringAsFixed(1)}%';
      color = const Color(0xFF16A34A);
    } else {
      label = '${comparison.changePercent!.toStringAsFixed(1)}%';
      color = const Color(0xFFDC2626);
    }

    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            _comparisonCaption(comparison),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 4.h),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }
}

class _LineTrendChart extends StatelessWidget {
  const _LineTrendChart({
    required this.points,
    required this.color,
    this.onPointTap,
    required this.valueSelector,
    required this.tooltipFormatter,
  });

  final List<TrendSeriesPointEntity> points;
  final Color color;
  final ValueChanged<TrendSeriesPointEntity>? onPointTap;
  final int Function(TrendSeriesPointEntity point) valueSelector;
  final String Function(TrendSeriesPointEntity point) tooltipFormatter;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: 260,
        child: Center(child: Text('Belum ada data.')),
      );
    }

    final double maxY = _resolveMaxY(
      points.map((TrendSeriesPointEntity point) => valueSelector(point)),
    );

    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
              if (!event.isInterestedForInteractions ||
                  event is! FlTapUpEvent ||
                  response?.lineBarSpots == null ||
                  response!.lineBarSpots!.isEmpty) {
                return;
              }
              final int index = response.lineBarSpots!.first.x.toInt();
              if (index >= 0 && index < points.length) {
                onPointTap?.call(points[index]);
              }
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF0F172A),
              getTooltipItems: (List<LineBarSpot> spots) {
                return spots
                    .map((LineBarSpot spot) {
                      final TrendSeriesPointEntity point =
                          points[spot.x.toInt()];
                      return LineTooltipItem(
                        tooltipFormatter(point),
                        TextStyle(color: Colors.white, fontSize: 12.sp),
                      );
                    })
                    .toList(growable: false);
              },
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0xFFE2E8F0), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: maxY / 4,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    _compactAxisLabel(value.toInt()),
                    style: TextStyle(fontSize: 10.sp),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: _bottomInterval(points.length),
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      points[index].shortLabel,
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: FlDotData(show: points.length <= 12),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.12),
              ),
              spots: List<FlSpot>.generate(points.length, (int index) {
                return FlSpot(
                  index.toDouble(),
                  valueSelector(points[index]).toDouble(),
                );
              }, growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownBarChart extends StatelessWidget {
  const _BreakdownBarChart({
    required this.items,
    required this.color,
    this.onBarTap,
    this.metricLabelBuilder,
  });

  final List<TrendBreakdownEntity> items;
  final Color color;
  final ValueChanged<TrendBreakdownEntity>? onBarTap;
  final String Function(TrendBreakdownEntity item)? metricLabelBuilder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SizedBox(
        height: 260,
        child: Center(child: Text('Belum ada data.')),
      );
    }

    final double maxY = _resolveMaxY(
      items.map((TrendBreakdownEntity item) => item.totalQuantity),
    );

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          barTouchData: BarTouchData(
            touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
              if (!event.isInterestedForInteractions ||
                  event is! FlTapUpEvent ||
                  response?.spot == null) {
                return;
              }
              final int index = response!.spot!.touchedBarGroupIndex;
              if (index >= 0 && index < items.length) {
                onBarTap?.call(items[index]);
              }
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF0F172A),
              getTooltipItem:
                  (
                    BarChartGroupData group,
                    int groupIndex,
                    BarChartRodData rod,
                    int rodIndex,
                  ) {
                    final TrendBreakdownEntity item = items[group.x.toInt()];
                    return BarTooltipItem(
                      '${item.label}\n${metricLabelBuilder?.call(item) ?? '${item.totalQuantity} item'}\n${formatCurrency(item.totalSales)}',
                      TextStyle(color: Colors.white, fontSize: 12.sp),
                    );
                  },
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0xFFE2E8F0), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY / 4,
                getTitlesWidget: (double value, TitleMeta meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10.sp),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int index = value.toInt();
                  if (index < 0 || index >= items.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      _trimLabel(items[index].label),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List<BarChartGroupData>.generate(items.length, (
            int index,
          ) {
            return BarChartGroupData(
              x: index,
              barRods: <BarChartRodData>[
                BarChartRodData(
                  toY: items[index].totalQuantity.toDouble(),
                  color: color,
                  width: 20,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(6.r),
                  ),
                ),
              ],
            );
          }, growable: false),
        ),
      ),
    );
  }
}

class _TrendLoadingState extends StatelessWidget {
  const _TrendLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _LoadingBlock(height: 96),
        SizedBox(height: 16.h),
        _LoadingBlock(height: 320),
        SizedBox(height: 16.h),
        _LoadingBlock(height: 320),
      ],
    );
  }
}

class _MovementList extends StatelessWidget {
  const _MovementList({required this.items});

  final List<TrendMovementEntity> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(child: Text('Belum ada penurunan di range ini.')),
      );
    }

    return Column(
      children: items
          .map((TrendMovementEntity item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.label,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${item.previousQuantity} -> ${item.currentQuantity} item',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      item.quantityDelta.toString(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _BucketTransactionSheet extends StatelessWidget {
  const _BucketTransactionSheet({
    required this.title,
    required this.transactions,
  });

  final String title;
  final List<TransactionEntity> transactions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 6.h),
            Text(
              '${transactions.length} transaksi',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16.h),
            if (transactions.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Text('Belum ada transaksi di bucket ini.'),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (_, int index) {
                    final TransactionEntity tx = transactions[index];
                    return Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  tx.invoiceNumber,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  formatDateTime(tx.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            formatCurrency(tx.totalAmount),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(24.r),
      ),
    );
  }
}

class _EmptyTrendState extends StatelessWidget {
  const _EmptyTrendState({required this.range});

  final TrendRange range;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.show_chart,
            size: 36,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Belum ada data ${_rangeLabel(range).toLowerCase()}.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8.h),
          Text(
            'Tambah transaksi dulu biar grafik muncul.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

double _resolveMaxY(Iterable<int> values) {
  final int maxValue = values.isEmpty ? 0 : values.reduce(math.max);
  if (maxValue <= 0) {
    return 4;
  }

  return (maxValue * 1.2).ceilToDouble();
}

double _bottomInterval(int length) {
  if (length <= 8) {
    return 1;
  }
  if (length <= 16) {
    return 2;
  }
  return 4;
}

String _trimLabel(String value) {
  if (value.length <= 8) {
    return value;
  }
  return '${value.substring(0, 8)}…';
}

String _compactAxisLabel(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(value >= 10000000 ? 0 : 1)}jt';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1)}rb';
  }
  return '$value';
}

String _rangeLabel(TrendRange range) {
  switch (range) {
    case TrendRange.daily:
      return 'Harian';
    case TrendRange.weekly:
      return 'Mingguan';
    case TrendRange.monthly:
      return 'Bulanan';
    case TrendRange.yearly:
      return 'Tahunan';
    case TrendRange.custom:
      return 'Custom';
  }
}

String _rangeDescription(TrendRange range, {TrendDateFilterEntity? filter}) {
  switch (range) {
    case TrendRange.daily:
      return 'Penjualan per jam hari ini';
    case TrendRange.weekly:
      return 'Penjualan 7 hari terakhir';
    case TrendRange.monthly:
      return 'Penjualan rolling 30 hari per bucket mingguan';
    case TrendRange.yearly:
      return 'Penjualan 12 bulan terakhir';
    case TrendRange.custom:
      if (filter == null) {
        return 'Penjualan custom range';
      }
      return 'Penjualan ${_filterLabel(filter)}';
  }
}

String _filterLabel(TrendDateFilterEntity filter) {
  return '${filter.start.day}/${filter.start.month} - ${filter.end.day}/${filter.end.month}';
}

String _comparisonCaption(TrendComparisonEntity comparison) {
  if (comparison.changePercent == 0) {
    return 'Sama dengan periode lalu';
  }
  return 'vs periode sebelumnya';
}
