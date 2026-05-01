import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../domain/cart_domain/domain/entities/cart_item_entity.dart';
import '../../../../domain/product_domain/domain/entities/product_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../product/presentation/cubit/product_cubit.dart';
import '../../../product/presentation/cubit/product_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCubit>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lariss POS'),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.push(AppRouter.categoriesPath),
            child: const Text('Kategori'),
          ),
          TextButton(
            onPressed: () => context.push(AppRouter.productsPath),
            child: const Text('Produk'),
          ),
          TextButton(
            onPressed: () => context.push(AppRouter.stockPath),
            child: const Text('Stok'),
          ),
        ],
      ),
      body: BlocListener<CartCubit, CartState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<CartCubit>().clearError();
        },
        child: SafeArea(
          child: BlocBuilder<ProductCubit, ProductState>(
            builder: (context, productState) {
              final CartState cartState = context.watch<CartCubit>().state;
              final List<ProductEntity> activeProducts = productState.products
                  .where((ProductEntity product) => product.isActive)
                  .toList(growable: false);

              return Stack(
                children: <Widget>[
                  RefreshIndicator(
                    onRefresh: () =>
                        context.read<ProductCubit>().loadProducts(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        cartState.isEmpty ? 24 : 220,
                      ),
                      children: <Widget>[
                        _HeaderCard(
                          lowStockCount: activeProducts
                              .where((product) => product.isLowStock)
                              .length,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Daftar produk',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        if (productState.status == ProductStatus.loading &&
                            activeProducts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (productState.status == ProductStatus.failure &&
                            activeProducts.isEmpty)
                          _InfoCard(
                            title: 'Produk gagal dimuat',
                            message:
                                productState.errorMessage ??
                                'Coba refresh lagi.',
                          )
                        else if (activeProducts.isEmpty)
                          const _InfoCard(
                            title: 'Belum ada produk aktif',
                            message:
                                'Cart Day 7 sudah siap. Tambahkan produk di progress product supaya transaksi bisa langsung dipakai.',
                          )
                        else
                          ...activeProducts.map(
                            (product) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ProductCard(
                                product: product,
                                quantityInCart: _findQuantity(
                                  cartState.items,
                                  product.id,
                                ),
                                onAdd: product.isOutOfStock
                                    ? null
                                    : () => context.read<CartCubit>().addItem(
                                        product,
                                      ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!cartState.isEmpty)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _CartSummary(
                        state: cartState,
                        onDecrement: context
                            .read<CartCubit>()
                            .decrementQuantity,
                        onIncrement: context
                            .read<CartCubit>()
                            .incrementQuantity,
                        onRemove: context.read<CartCubit>().removeItem,
                        onCheckout: () => context.push(AppRouter.checkoutPath),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  int _findQuantity(List<CartItemEntity> items, String productId) {
    for (final CartItemEntity item in items) {
      if (item.productId == productId) {
        return item.quantity;
      }
    }

    return 0;
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.lowStockCount});

  final int lowStockCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('KasirLite', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Fokus transaksi cepat dan offline.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: lowStockCount > 0
                  ? const Color(0xFFFFFBEB)
                  : const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              lowStockCount > 0
                  ? '$lowStockCount produk stok menipis'
                  : 'Belum ada alert stok kritis',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.quantityInCart,
    required this.onAdd,
  });

  final ProductEntity product;
  final int quantityInCart;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(product.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      _formatCurrency(product.sellingPrice),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              if (product.isOutOfStock)
                const _StatusBadge(
                  label: 'Stok habis',
                  backgroundColor: Color(0xFFFEE2E2),
                  foregroundColor: Color(0xFFB91C1C),
                )
              else if (product.isLowStock)
                const _StatusBadge(
                  label: 'Menipis',
                  backgroundColor: Color(0xFFFFFBEB),
                  foregroundColor: Color(0xFFB45309),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Stok tersedia: ${product.currentStock}',
            style: theme.textTheme.bodyMedium,
          ),
          if (quantityInCart > 0) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              'Di cart: $quantityInCart',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onAdd,
              child: Text(
                product.isOutOfStock ? 'Tidak bisa dijual' : 'Tambah ke cart',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.state,
    required this.onDecrement,
    required this.onIncrement,
    required this.onRemove,
    required this.onCheckout,
  });

  final CartState state;
  final ValueChanged<String> onDecrement;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onRemove;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('Cart aktif', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  '${state.totalItems} item',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final CartItemEntity item = state.items[index];

                  return _CartItemTile(
                    item: item,
                    onDecrement: () => onDecrement(item.productId),
                    onIncrement: () => onIncrement(item.productId),
                    onRemove: () => onRemove(item.productId),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Text('Total', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  _formatCurrency(state.totalAmount),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onCheckout,
                child: const Text('Checkout sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onDecrement,
    required this.onIncrement,
    required this.onRemove,
  });

  final CartItemEntity item;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
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
                  item.productName,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Text(
            _formatCurrency(item.subtotal),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _QtyButton(icon: Icons.remove, onPressed: onDecrement),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${item.quantity}',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              _QtyButton(icon: Icons.add, onPressed: onIncrement),
              const Spacer(),
              Text(
                'Maks ${item.availableStock}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: foregroundColor),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

String _formatCurrency(int amount) {
  final String digits = amount.toString();
  final StringBuffer buffer = StringBuffer();
  int counter = 0;

  for (int index = digits.length - 1; index >= 0; index--) {
    buffer.write(digits[index]);
    counter++;

    if (counter % 3 == 0 && index != 0) {
      buffer.write('.');
    }
  }

  return 'Rp${buffer.toString().split('').reversed.join()}';
}
