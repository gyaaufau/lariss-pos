import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/stock_domain/domain/entities/stock_movement_entity.dart';
import '../cubit/stock_detail_cubit.dart';

class StockDetailPage extends StatefulWidget {
  const StockDetailPage({required this.productId, super.key});

  final String productId;

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockDetailCubit>().loadDetail(widget.productId);
    });
  }

  Future<void> _openUpdate() async {
    await context.push(AppRouter.stockUpdatePath(widget.productId));
    if (!mounted) {
      return;
    }
    await context.read<StockDetailCubit>().loadDetail(widget.productId);
  }

  String _movementLabel(StockMovementEntity movement) {
    switch (movement.type) {
      case 'stock_in':
        return 'Stock in';
      case 'stock_out':
        return 'Stock out';
      case 'adjustment':
        return 'Adjustment';
      default:
        return movement.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail stok')),
      body: BlocConsumer<StockDetailCubit, StockDetailState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == StockDetailStatus.loading ||
              state.status == StockDetailStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = state.product;
          if (product == null) {
            return const Center(child: Text('Produk stok tidak ditemukan.'));
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        label: 'Stok sekarang',
                        value: '${product.currentStock}',
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Minimum stok',
                        value: '${product.minimumStock}',
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Harga jual',
                        value: formatCurrency(product.sellingPrice),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openUpdate,
                    icon: const Icon(Icons.sync_alt),
                    label: const Text('Update stok'),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Riwayat perubahan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (state.movements.isEmpty)
                  const _EmptyMovementState()
                else
                  ...state.movements.map(
                    (movement) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _movementLabel(movement),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Jumlah',
                              value: '${movement.quantity}',
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Sebelum',
                              value: '${movement.stockBefore}',
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Sesudah',
                              value: '${movement.stockAfter}',
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Waktu',
                              value: formatDateTime(movement.createdAt),
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
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(label)),
        const SizedBox(width: 16),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}

class _EmptyMovementState extends StatelessWidget {
  const _EmptyMovementState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        'Belum ada riwayat perubahan stok untuk produk ini.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
