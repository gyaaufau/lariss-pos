import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/stock_domain/domain/entities/stock_product_entity.dart';
import '../../../../domain/stock_domain/domain/entities/stock_update_type.dart';
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

  Future<void> _openStockEditor(StockProductEntity product) async {
    final StockUpdateType? type = await showModalBottomSheet<StockUpdateType>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _StockEditorSheet(product: product),
    );

    if (type == null || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Update stok ${type.label.toLowerCase()} berhasil.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Stok')),
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
                    'Semua perubahan stok akan dicatat ke stock movement. Low stock juga ditandai otomatis.',
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
                                  product: product,
                                  onTap: () => _openStockEditor(product),
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

class _StockEditorSheet extends StatefulWidget {
  const _StockEditorSheet({required this.product});

  final StockProductEntity product;

  @override
  State<_StockEditorSheet> createState() => _StockEditorSheetState();
}

class _StockEditorSheetState extends State<_StockEditorSheet> {
  late final TextEditingController _quantityController;
  StockUpdateType _selectedType = StockUpdateType.stockIn;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final int? quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan angka stok yang valid.')),
      );
      return;
    }

    final bool updated = await context.read<StockCubit>().updateProductStock(
      productId: widget.product.id,
      type: _selectedType,
      quantity: quantity,
    );

    if (!mounted || !updated) {
      return;
    }

    Navigator.of(context).pop(_selectedType);
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdjustment = _selectedType == StockUpdateType.adjustment;
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Ubah stok ${widget.product.name}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Stok sekarang: ${widget.product.currentStock}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<StockUpdateType>(
            initialValue: _selectedType,
            items: StockUpdateType.values
                .map(
                  (type) => DropdownMenuItem<StockUpdateType>(
                    value: type,
                    child: Text(type.label),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedType = value;
              });
            },
            decoration: const InputDecoration(labelText: 'Tipe perubahan'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: isAdjustment ? 'Stok akhir' : 'Jumlah',
              hintText: isAdjustment ? 'Contoh: 20' : 'Contoh: 5',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: const Text('Simpan perubahan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockProductCard extends StatelessWidget {
  const _StockProductCard({required this.product, required this.onTap});

  final StockProductEntity product;
  final VoidCallback onTap;

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
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _StockChip(
                label: product.isOutOfStock
                    ? 'Stok habis'
                    : product.isLowStock
                    ? 'Low stock'
                    : 'Aman',
                color: product.isOutOfStock
                    ? const Color(0xFFDC2626)
                    : product.isLowStock
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF16A34A),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Stok sekarang: ${product.currentStock}'),
          const SizedBox(height: 4),
          Text('Minimum stok: ${product.minimumStock}'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              child: const Text('Ubah stok'),
            ),
          ),
        ],
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  const _StockChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _EmptyStockState extends StatelessWidget {
  const _EmptyStockState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            'Belum ada produk untuk dikelola.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Stock feature siap, tapi daftar produk masih kosong. Setelah feature produk dibuat, semua item akan muncul di sini.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
