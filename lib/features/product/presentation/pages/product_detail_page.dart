import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_status_chip.dart';
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
              padding: EdgeInsets.all(16.r),
              children: <Widget>[
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          _Tag(
                            label: _categoryName(state, product.categoryId),
                            color: const Color(0xFFDBEAFE),
                          ),
                          product.isActive
                              ? AppStatusChip.active()
                              : AppStatusChip.inactive(),
                          product.isOutOfStock
                              ? AppStatusChip.outOfStock()
                              : product.isLowStock
                              ? AppStatusChip.lowStock()
                              : AppStatusChip.safe(),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                _SectionCard(
                  child: Column(
                    children: <Widget>[
                      _InfoRow(
                        label: 'Harga jual',
                        value: formatCurrency(product.sellingPrice),
                      ),
                      SizedBox(height: 12.h),
                      _InfoRow(
                        label: 'Stok sekarang',
                        value: '${product.currentStock}',
                      ),
                      SizedBox(height: 12.h),
                      _InfoRow(
                        label: 'Minimum stok',
                        value: '${product.minimumStock}',
                      ),
                      SizedBox(height: 12.h),
                      _InfoRow(
                        label: 'Dibuat',
                        value: formatDateTime(product.createdAt),
                      ),
                      SizedBox(height: 12.h),
                      _InfoRow(
                        label: 'Diubah',
                        value: formatDateTime(product.updatedAt),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit produk'),
                  ),
                ),
                SizedBox(height: 12.h),
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
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
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
        SizedBox(width: 16.w),
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(label),
    );
  }
}
