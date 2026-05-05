import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../cubit/stock_cubit.dart';
import '../cubit/stock_state.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockCubit>().loadStockOverview();
    });
  }

  Future<void> _openDetail(String productId) async {
    await context.push(AppRouter.stockDetailPath(productId));
    if (!mounted) {
      return;
    }
    await context.read<StockCubit>().loadStockOverview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola stok')),
      body: BlocConsumer<StockCubit, StockState>(
        listener: (context, state) {
          if (state.errorMessage != null &&
              state.status == StockStatus.failure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final bool isLoading =
              state.status == StockStatus.loading && state.products.isEmpty;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Pantau dan ubah stok produk.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Detail stok dan update sekarang dibuka di layar terpisah.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _SummaryCard(
                          title: 'Produk aktif',
                          value: '${state.products.length}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Low stock',
                          value: '${state.lowStockProducts.length}',
                          accentColor: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : state.products.isEmpty
                        ? const _EmptyStockState()
                        : RefreshIndicator(
                            onRefresh: () =>
                                context.read<StockCubit>().loadStockOverview(),
                            child: ListView.separated(
                              itemCount: state.products.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final product = state.products[index];
                                return _StockProductCard(
                                  name: product.name,
                                  stock: product.currentStock,
                                  minimumStock: product.minimumStock,
                                  isLowStock: product.isLowStock,
                                  isOutOfStock: product.isOutOfStock,
                                  onTap: () => _openDetail(product.id),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    this.accentColor = const Color(0xFF2563EB),
  });

  final String title;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: accentColor),
          ),
        ],
      ),
    );
  }
}

class _StockProductCard extends StatelessWidget {
  const _StockProductCard({
    required this.name,
    required this.stock,
    required this.minimumStock,
    required this.isLowStock,
    required this.isOutOfStock,
    required this.onTap,
  });

  final String name;
  final int stock;
  final int minimumStock;
  final bool isLowStock;
  final bool isOutOfStock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color chipColor = isOutOfStock
        ? const Color(0xFFFEE2E2)
        : isLowStock
        ? const Color(0xFFFFEDD5)
        : const Color(0xFFDCFCE7);
    final String chipLabel = isOutOfStock
        ? 'Stok habis'
        : isLowStock
        ? 'Low stock'
        : 'Aman';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Stok $stock • Minimum $minimumStock'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(chipLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStockState extends StatelessWidget {
  const _EmptyStockState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Belum ada produk aktif.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Aktifkan atau buat produk dulu supaya stok bisa dikelola.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
