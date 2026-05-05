import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCubit>().loadProducts();
    });
  }

  Future<void> _openCreate() async {
    await context.push(AppRouter.productCreatePath);
    if (!mounted) {
      return;
    }
    await context.read<ProductCubit>().loadProducts();
  }

  Future<void> _openDetail(String productId) async {
    await context.push(AppRouter.productDetailPath(productId));
    if (!mounted) {
      return;
    }
    await context.read<ProductCubit>().loadProducts();
  }

  String _categoryName(ProductState state, String categoryId) {
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
      appBar: AppBar(title: const Text('Produk')),
      floatingActionButton: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state.categories.isEmpty) {
            return FloatingActionButton.extended(
              onPressed: () => context.push(AppRouter.categoriesPath),
              icon: const Icon(Icons.category_outlined),
              label: const Text('Buat kategori'),
            );
          }

          return FloatingActionButton.extended(
            onPressed: _openCreate,
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
          );
        },
      ),
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state.errorMessage != null &&
              state.status == ProductStatus.failure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final bool isLoading =
              state.status == ProductStatus.loading && state.products.isEmpty;

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => context.read<ProductCubit>().loadProducts(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Text(
                    'Kelola produk untuk transaksi harian.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'List, detail, dan form dipisah agar alur lebih siap rilis.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  if (state.categories.isEmpty)
                    _MissingCategoryCard(
                      onTap: () => context.push(AppRouter.categoriesPath),
                    )
                  else if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.products.isEmpty)
                    const _EmptyProductState()
                  else
                    ...state.products.map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ProductCard(
                          name: product.name,
                          categoryName: _categoryName(
                            state,
                            product.categoryId,
                          ),
                          price: formatCurrency(product.sellingPrice),
                          stockLabel:
                              'Stok ${product.currentStock} • Min ${product.minimumStock}',
                          isActive: product.isActive,
                          isLowStock: product.isLowStock,
                          onTap: () => _openDetail(product.id),
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

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.name,
    required this.categoryName,
    required this.price,
    required this.stockLabel,
    required this.isActive,
    required this.isLowStock,
    required this.onTap,
  });

  final String name;
  final String categoryName;
  final String price;
  final String stockLabel;
  final bool isActive;
  final bool isLowStock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 8),
              Text(categoryName),
              const SizedBox(height: 4),
              Text(price, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _Tag(
                    label: isActive ? 'Aktif' : 'Nonaktif',
                    color: isActive
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFE2E8F0),
                  ),
                  _Tag(
                    label: stockLabel,
                    color: isLowStock
                        ? const Color(0xFFFFEDD5)
                        : const Color(0xFFDBEAFE),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

class _MissingCategoryCard extends StatelessWidget {
  const _MissingCategoryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Buat kategori dulu.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Produk butuh kategori aktif sebelum bisa dibuat.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onTap, child: const Text('Buka kategori')),
        ],
      ),
    );
  }
}

class _EmptyProductState extends StatelessWidget {
  const _EmptyProductState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Belum ada produk.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tambah produk pertama dari tombol di kanan bawah.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
