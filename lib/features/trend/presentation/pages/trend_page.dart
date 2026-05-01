import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/trend_domain/domain/entities/daily_sales_entity.dart';
import '../../../../domain/trend_domain/domain/entities/top_product_entity.dart';
import '../../../../domain/trend_domain/domain/entities/trend_summary_entity.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Trend penjualan')),
      body: BlocConsumer<TrendCubit, TrendState>(
        listener: (context, state) {
          if (state.status == TrendStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final summary = state.summary;
          final isLoading =
              state.status == TrendStatus.loading && summary == null;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : summary == null || _isEmpty(summary)
                  ? const _EmptyTrendState()
                  : RefreshIndicator(
                      onRefresh: () => context.read<TrendCubit>().loadTrend(),
                      child: ListView(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _MetricCard(
                                  label: 'Total sales',
                                  value: _formatCurrency(summary.totalSales),
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricCard(
                                  label: 'Transaksi',
                                  value: '${summary.totalTransactions}',
                                  color: const Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _Panel(
                            title: 'Penjualan harian',
                            child: Column(
                              children: summary.dailySales
                                  .map((entry) => _DailySalesRow(entry: entry))
                                  .toList(growable: false),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _Panel(
                            title: 'Top product',
                            child: Column(
                              children: summary.topProducts
                                  .map((item) => _TopProductRow(item: item))
                                  .toList(growable: false),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DailySalesRow extends StatelessWidget {
  const _DailySalesRow({required this.entry});

  final DailySalesEntity entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              entry.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(width: 12),
          Text('${entry.totalTransactions} trx'),
          const SizedBox(width: 12),
          Text(
            _formatCurrency(entry.totalSales),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  const _TopProductRow({required this.item});

  final TopProductEntity item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.totalQuantity} item terjual',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatCurrency(item.totalSales),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _EmptyTrendState extends StatelessWidget {
  const _EmptyTrendState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          const SizedBox(height: 16),
          Text(
            'Belum ada data trend.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Begitu transaksi mulai tercatat, total sales, transaksi harian, dan top product akan tampil di sini.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

bool _isEmpty(TrendSummaryEntity summary) {
  return summary.totalSales == 0 &&
      summary.totalTransactions == 0 &&
      summary.dailySales.isEmpty &&
      summary.topProducts.isEmpty;
}

String _formatCurrency(int value) => 'Rp$value';
