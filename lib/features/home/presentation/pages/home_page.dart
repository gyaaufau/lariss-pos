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

enum _ProductViewMode { list, grid }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _ProductViewMode _productViewMode = _ProductViewMode.list;

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
      appBar: AppBar(title: const Text('Lariss POS')),
      body: BlocListener<CartCubit, CartState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) async {
          final String message = state.errorMessage!;
          final CartCubit cartCubit = context.read<CartCubit>();

          if (message.contains('melebihi stok tersedia')) {
            await showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Stok tidak cukup'),
                  content: Text(message),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Oke'),
                    ),
                  ],
                );
              },
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }

          if (!context.mounted) {
            return;
          }

          cartCubit.clearError();
        },
        child: SafeArea(
          child: BlocBuilder<ProductCubit, ProductState>(
            builder: (context, productState) {
              final CartState cartState = context.watch<CartCubit>().state;
              final List<ProductEntity> activeProducts = productState.products
                  .where((ProductEntity product) => product.isActive)
                  .toList(growable: false);
              final int lowStockCount = activeProducts
                  .where((ProductEntity product) => product.isLowStock)
                  .length;

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
                        cartState.isEmpty ? 24 : 112,
                      ),
                      children: <Widget>[
                        if (lowStockCount > 0) ...<Widget>[
                          _AlertNotification(lowStockCount: lowStockCount),
                          const SizedBox(height: 20),
                        ],
                        _ProductSectionHeader(
                          viewMode: _productViewMode,
                          onViewModeChanged: (_ProductViewMode viewMode) {
                            setState(() {
                              _productViewMode = viewMode;
                            });
                          },
                        ),
                        if (_productViewMode ==
                            _ProductViewMode.grid) ...<Widget>[
                          const SizedBox(height: 6),
                          Text(
                            'Klik produk untuk masukkan ke cart',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
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
                          _ProductCollection(
                            products: activeProducts,
                            viewMode: _productViewMode,
                            quantityForProduct: (ProductEntity product) =>
                                _findQuantity(cartState.items, product.id),
                            onAdd: (ProductEntity product) =>
                                context.read<CartCubit>().addItem(product),
                          ),
                      ],
                    ),
                  ),
                  if (!cartState.isEmpty)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _CheckoutBar(
                        state: cartState,
                        onPressed: _openCartSummarySheet,
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

  Future<void> _openCartSummarySheet() async {
    final CartCubit cartCubit = context.read<CartCubit>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return BlocProvider.value(
          value: cartCubit,
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              return _CartSummarySheet(
                state: cartState,
                onDecrement: context.read<CartCubit>().decrementQuantity,
                onIncrement: context.read<CartCubit>().incrementQuantity,
                onRemove: context.read<CartCubit>().removeItem,
                onCheckout: () {
                  Navigator.of(bottomSheetContext).pop();
                  context.push(AppRouter.checkoutPath);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _ProductSectionHeader extends StatelessWidget {
  const _ProductSectionHeader({
    required this.viewMode,
    required this.onViewModeChanged,
  });

  final _ProductViewMode viewMode;
  final ValueChanged<_ProductViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text('Daftar produk', style: theme.textTheme.titleMedium),
        ),
        _ViewModeButton(
          icon: Icons.view_list_rounded,
          tooltip: 'List view',
          isSelected: viewMode == _ProductViewMode.list,
          onPressed: () => onViewModeChanged(_ProductViewMode.list),
        ),
        const SizedBox(width: 8),
        _ViewModeButton(
          icon: Icons.grid_view_rounded,
          tooltip: 'Grid view',
          isSelected: viewMode == _ProductViewMode.grid,
          onPressed: () => onViewModeChanged(_ProductViewMode.grid),
        ),
      ],
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  const _ViewModeButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Ink(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDBEAFE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

class _ProductCollection extends StatelessWidget {
  const _ProductCollection({
    required this.products,
    required this.viewMode,
    required this.quantityForProduct,
    required this.onAdd,
  });

  final List<ProductEntity> products;
  final _ProductViewMode viewMode;
  final int Function(ProductEntity product) quantityForProduct;
  final ValueChanged<ProductEntity> onAdd;

  @override
  Widget build(BuildContext context) {
    if (viewMode == _ProductViewMode.grid) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool useThreeColumns = constraints.maxWidth >= 960;
          final int crossAxisCount = useThreeColumns ? 3 : 2;
          final double mainAxisExtent = useThreeColumns ? 188 : 196;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: mainAxisExtent,
            ),
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              final ProductEntity product = products[index];

              return _ProductCard(
                product: product,
                quantityInCart: quantityForProduct(product),
                onAdd: product.isOutOfStock ? null : () => onAdd(product),
                enableCardTapToAdd: true,
              );
            },
          );
        },
      );
    }

    return Column(
      children: products
          .map(
            (ProductEntity product) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProductCard(
                product: product,
                quantityInCart: quantityForProduct(product),
                onAdd: product.isOutOfStock ? null : () => onAdd(product),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _AlertNotification extends StatelessWidget {
  const _AlertNotification({required this.lowStockCount});

  final int lowStockCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (lowStockCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.notification_important_outlined,
            color: Color(0xFFB45309),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$lowStockCount produk stok menipis',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
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
    this.enableCardTapToAdd = false,
  });

  final ProductEntity product;
  final int quantityInCart;
  final VoidCallback? onAdd;
  final bool enableCardTapToAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isGridCard = enableCardTapToAdd;
    final Color accentColor = product.isOutOfStock
        ? const Color(0xFFB91C1C)
        : product.isLowStock
        ? const Color(0xFFB45309)
        : const Color(0xFF2563EB);
    final Color iconSurfaceColor = product.isOutOfStock
        ? const Color(0xFFFEE2E2)
        : product.isLowStock
        ? const Color(0xFFFFFBEB)
        : const Color(0xFFF8FAFC);
    final Widget child = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(isGridCard ? 14 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: isGridCard ? 44 : 48,
                    height: isGridCard ? 44 : 48,
                    decoration: BoxDecoration(
                      color: iconSurfaceColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      color: accentColor,
                      size: isGridCard ? 22 : 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          product.name,
                          maxLines: isGridCard ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatCurrency(product.sellingPrice),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isGridCard && product.isOutOfStock)
                    const _StatusBadge(
                      label: 'Stok habis',
                      backgroundColor: Color(0xFFFEE2E2),
                      foregroundColor: Color(0xFFB91C1C),
                    )
                  else if (!isGridCard && product.isLowStock)
                    const _StatusBadge(
                      label: 'Menipis',
                      backgroundColor: Color(0xFFFFFBEB),
                      foregroundColor: Color(0xFFB45309),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _ProductInfoPill(
                    icon: Icons.inventory_2_outlined,
                    label: 'Stok ${product.currentStock}',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                  ),
                  _ProductInfoPill(
                    icon: Icons.warning_amber_rounded,
                    label: 'Min ${product.minimumStock}',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF64748B),
                  ),
                ],
              ),
              if (!isGridCard && quantityInCart > 0) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.shopping_cart_checkout_rounded,
                        size: 18,
                        color: Color(0xFF0369A1),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$quantityInCart item sudah di cart',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF0C4A6E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!enableCardTapToAdd) ...<Widget>[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onAdd,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      product.isOutOfStock
                          ? 'Tidak bisa dijual'
                          : 'Tambah ke cart',
                    ),
                  ),
                ),
              ] else if (product.isOutOfStock) ...<Widget>[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Stok habis, tidak bisa ditambah',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isGridCard && quantityInCart <= 0 && product.isOutOfStock)
          const Positioned(
            top: 10,
            right: 10,
            child: _StatusBadge(
              label: 'Stok habis',
              backgroundColor: Color(0xFFFEE2E2),
              foregroundColor: Color(0xFFB91C1C),
            ),
          )
        else if (isGridCard && quantityInCart <= 0 && product.isLowStock)
          const Positioned(
            top: 10,
            right: 10,
            child: _StatusBadge(
              label: 'Menipis',
              backgroundColor: Color(0xFFFFFBEB),
              foregroundColor: Color(0xFFB45309),
            ),
          ),
        if (isGridCard && quantityInCart > 0)
          Positioned(
            top: 10,
            right: 10,
            child: _StatusBadge(
              label: '$quantityInCart',
              backgroundColor: const Color(0xFFE0F2FE),
              foregroundColor: const Color(0xFF0C4A6E),
            ),
          ),
      ],
    );

    if (!enableCardTapToAdd) {
      return child;
    }

    return _InteractiveProductCard(onTap: onAdd, child: child);
  }
}

class _InteractiveProductCard extends StatefulWidget {
  const _InteractiveProductCard({required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  State<_InteractiveProductCard> createState() =>
      _InteractiveProductCardState();
}

class _InteractiveProductCardState extends State<_InteractiveProductCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _isPressed
                ? const Color(0xFF2563EB)
                : const Color(0x00000000),
            width: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            borderRadius: BorderRadius.circular(20),
            splashColor: const Color(0xFF2563EB).withAlpha(18),
            highlightColor: const Color(0xFF2563EB).withAlpha(10),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.state, required this.onPressed});

  final CartState state;
  final VoidCallback onPressed;

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
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Cart aktif', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${state.totalItems} item • ${_formatCurrency(state.totalAmount)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(onPressed: onPressed, child: const Text('Checkout')),
          ],
        ),
      ),
    );
  }
}

class _CartSummarySheet extends StatelessWidget {
  const _CartSummarySheet({
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

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
              constraints: const BoxConstraints(maxHeight: 320),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
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
                    Text(
                      item.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(item.subtotal),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 18),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Stok maks ${item.availableStock}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _QtyButton(icon: Icons.remove, onPressed: onDecrement),
                  Container(
                    width: 36,
                    alignment: Alignment.center,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  _QtyButton(icon: Icons.add, onPressed: onIncrement),
                ],
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
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
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

class _ProductInfoPill extends StatelessWidget {
  const _ProductInfoPill({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
