import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../cubit/product_detail_cubit.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({required this.productId, super.key});

  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDetailCubit>().loadProduct(widget.productId);
    });
  }

  Future<void> _openEdit() async {
    await context.push(AppRouter.productEditPath(widget.productId));
    if (!mounted) {
      return;
    }
    await context.read<ProductDetailCubit>().loadProduct(widget.productId);
  }

  Future<void> _delete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus produk'),
          content: const Text('Produk akan disembunyikan dari daftar.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final deleted = await context
        .read<ProductDetailCubit>()
        .deleteCurrentProduct();
    if (!mounted || !deleted) {
      return;
    }

    context.pop();
  }

  String _categoryName(ProductDetailState state, String categoryId) {
    for (final category in state.categories) {
      if (category.id == categoryId) {
        return category.name;
      }
    }
    return 'Tanpa kategori';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail produk')),
      body: BlocConsumer<ProductDetailCubit, ProductDetailState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == ProductDetailStatus.loading ||
              state.status == ProductDetailStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = state.product;
          if (product == null) {
            return const Center(child: Text('Produk tidak ditemukan.'));
          }

          final bool isDeleting = state.status == ProductDetailStatus.deleting;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          _Tag(
                            label: _categoryName(state, product.categoryId),
                            color: const Color(0xFFDBEAFE),
                          ),
                          _Tag(
                            label: product.isActive ? 'Aktif' : 'Nonaktif',
                            color: product.isActive
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFE2E8F0),
                          ),
                          _Tag(
                            label: product.isLowStock
                                ? 'Low stock'
                                : 'Stok aman',
                            color: product.isLowStock
                                ? const Color(0xFFFFEDD5)
                                : const Color(0xFFDCFCE7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  child: Column(
                    children: <Widget>[
                      _InfoRow(
                        label: 'Harga jual',
                        value: formatCurrency(product.sellingPrice),
                      ),
                      const SizedBox(height: 12),
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
                        label: 'Dibuat',
                        value: formatDateTime(product.createdAt),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Diubah',
                        value: formatDateTime(product.updatedAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit produk'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isDeleting ? null : _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(isDeleting ? 'Menghapus...' : 'Hapus produk'),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

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

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
