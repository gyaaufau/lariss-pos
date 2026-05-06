import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../domain/category_domain/domain/entities/category_entity.dart';
import '../../../../domain/cart_domain/domain/entities/cart_item_entity.dart';
import '../../../../domain/product_domain/domain/entities/product_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../profile/presentation/cubit/app_settings_cubit.dart';
import '../../../product/presentation/cubit/product_cubit.dart';
import '../../../product/presentation/cubit/product_state.dart';

enum _ProductViewMode { list, grid }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<_ProductViewMode> _productViewModeNotifier =
      ValueNotifier<_ProductViewMode>(_ProductViewMode.list);
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCubit>().loadProducts();
    });
  }

  @override
  void dispose() {
    _productViewModeNotifier.dispose();
    super.dispose();
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
              final bool showLowStockAlert = context
                  .watch<AppSettingsCubit>()
                  .state
                  .settings
                  .lowStockAlertEnabled;
              final CartState cartState = context.watch<CartCubit>().state;
              final List<ProductEntity> activeProducts = productState.products
                  .where((ProductEntity product) => product.isActive)
                  .toList(growable: false);
              final List<CategoryEntity> availableCategories =
                  _buildAvailableCategories(
                    products: activeProducts,
                    categories: productState.categories,
                  );
              final bool hasSelectedCategory = availableCategories.any(
                (CategoryEntity category) => category.id == _selectedCategoryId,
              );
              final String? effectiveCategoryId = hasSelectedCategory
                  ? _selectedCategoryId
                  : null;
              final List<ProductEntity> filteredProducts =
                  effectiveCategoryId == null
                  ? activeProducts
                  : activeProducts
                        .where(
                          (ProductEntity product) =>
                              product.categoryId == effectiveCategoryId,
                        )
                        .toList(growable: false);
              final List<ProductEntity> lowStockProducts = activeProducts
                  .where((ProductEntity product) => product.isLowStock)
                  .toList(growable: false);
              final int lowStockCount = showLowStockAlert
                  ? lowStockProducts.length
                  : 0;

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
                          _AlertNotification(
                            lowStockCount: lowStockCount,
                            onViewPressed: () =>
                                _showLowStockDialog(lowStockProducts),
                          ),
                          SizedBox(height: 20.h),
                        ],
                        ValueListenableBuilder<_ProductViewMode>(
                          valueListenable: _productViewModeNotifier,
                          builder: (context, viewMode, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _ProductSectionHeader(
                                  viewMode: viewMode,
                                  categories: availableCategories,
                                  selectedCategoryId: effectiveCategoryId,
                                  onViewModeChanged: (_ProductViewMode mode) {
                                    _productViewModeNotifier.value = mode;
                                  },
                                  onCategorySelected: (String? categoryId) {
                                    setState(() {
                                      _selectedCategoryId = categoryId;
                                    });
                                  },
                                ),
                                if (viewMode ==
                                    _ProductViewMode.grid) ...<Widget>[
                                  SizedBox(height: 6.h),
                                  Text(
                                    'Klik produk untuk masukkan ke cart',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                                SizedBox(height: 12.h),
                                if (productState.status ==
                                        ProductStatus.loading &&
                                    filteredProducts.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 48.h,
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else if (productState.status ==
                                        ProductStatus.failure &&
                                    filteredProducts.isEmpty)
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
                                        'Tambahkan produk aktif agar transaksi bisa langsung dipakai.',
                                  )
                                else if (filteredProducts.isEmpty)
                                  const _InfoCard(
                                    title: 'Produk kategori ini belum ada',
                                    message:
                                        'Pilih kategori lain atau tambah produk baru.',
                                  )
                                else
                                  _ProductCollection(
                                    products: filteredProducts,
                                    viewMode: viewMode,
                                    showLowStockAlert: showLowStockAlert,
                                    quantityForProduct:
                                        (ProductEntity product) =>
                                            _findQuantity(
                                              cartState.items,
                                              product.id,
                                            ),
                                    onAdd: (ProductEntity product) => context
                                        .read<CartCubit>()
                                        .addItem(product),
                                  ),
                              ],
                            );
                          },
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

  List<CategoryEntity> _buildAvailableCategories({
    required List<ProductEntity> products,
    required List<CategoryEntity> categories,
  }) {
    final Set<String> usedCategoryIds = products
        .map((ProductEntity product) => product.categoryId)
        .toSet();

    return categories
        .where(
          (CategoryEntity category) => usedCategoryIds.contains(category.id),
        )
        .toList(growable: false);
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

  Future<void> _showLowStockDialog(List<ProductEntity> products) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final ThemeData theme = Theme.of(dialogContext);

        return AlertDialog(
          title: const Text('Stok menipis'),
          contentPadding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 8.h),
          content: SizedBox(
            width: double.maxFinite,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: products.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final ProductEntity product = products[index];

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      product.name,
                      style: theme.textTheme.titleSmall,
                    ),
                    subtitle: Text(
                      'Stok ${product.currentStock} • Min ${product.minimumStock}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    leading: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFB45309),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}

class _ProductSectionHeader extends StatelessWidget {
  const _ProductSectionHeader({
    required this.viewMode,
    required this.categories,
    required this.selectedCategoryId,
    required this.onViewModeChanged,
    required this.onCategorySelected,
  });

  final _ProductViewMode viewMode;
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final ValueChanged<_ProductViewMode> onViewModeChanged;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
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
            SizedBox(width: 8.w),
            _ViewModeButton(
              icon: Icons.grid_view_rounded,
              tooltip: 'Grid view',
              isSelected: viewMode == _ProductViewMode.grid,
              onPressed: () => onViewModeChanged(_ProductViewMode.grid),
            ),
          ],
        ),
        if (categories.isNotEmpty) ...<Widget>[
          SizedBox(height: 12.h),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return _CategoryFilterChip(
                    label: 'Semua',
                    isSelected: selectedCategoryId == null,
                    onTap: () => onCategorySelected(null),
                  );
                }

                final CategoryEntity category = categories[index - 1];
                return _CategoryFilterChip(
                  label: category.name,
                  isSelected: selectedCategoryId == category.id,
                  onTap: () => onCategorySelected(category.id),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      side: BorderSide(
        color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999.r)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
          borderRadius: BorderRadius.circular(12.r),
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
    required this.showLowStockAlert,
    required this.quantityForProduct,
    required this.onAdd,
  });

  final List<ProductEntity> products;
  final _ProductViewMode viewMode;
  final bool showLowStockAlert;
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
                showLowStockAlert: showLowStockAlert,
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
              padding: EdgeInsets.only(bottom: 12.h),
              child: _ProductCard(
                product: product,
                quantityInCart: quantityForProduct(product),
                showLowStockAlert: showLowStockAlert,
                onAdd: product.isOutOfStock ? null : () => onAdd(product),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _AlertNotification extends StatelessWidget {
  const _AlertNotification({
    required this.lowStockCount,
    required this.onViewPressed,
  });

  final int lowStockCount;
  final VoidCallback onViewPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (lowStockCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(
              Icons.notification_important_outlined,
              color: Color(0xFFB45309),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$lowStockCount produk stok menipis',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: onViewPressed,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: const Color(0xFFB45309),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Lihat'),
                ),
              ],
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
    required this.showLowStockAlert,
    required this.onAdd,
    this.enableCardTapToAdd = false,
  });

  final ProductEntity product;
  final int quantityInCart;
  final bool showLowStockAlert;
  final VoidCallback? onAdd;
  final bool enableCardTapToAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isGridCard = enableCardTapToAdd;
    final bool isHighlightedLowStock =
        showLowStockAlert && product.isLowStock && !product.isOutOfStock;
    final Color accentColor = product.isOutOfStock
        ? const Color(0xFFB91C1C)
        : isHighlightedLowStock
        ? const Color(0xFFB45309)
        : const Color(0xFF2563EB);
    final Color iconSurfaceColor = product.isOutOfStock
        ? const Color(0xFFFEE2E2)
        : isHighlightedLowStock
        ? const Color(0xFFFFFBEB)
        : const Color(0xFFF8FAFC);
    final Widget child = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(isGridCard ? 14 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
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
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      color: accentColor,
                      size: isGridCard ? 22 : 24,
                    ),
                  ),
                  SizedBox(width: 12.w),
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
                        SizedBox(height: 8.h),
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
                  if (!isGridCard && quantityInCart > 0)
                    _CartCountBadge(count: quantityInCart)
                  else if (!isGridCard && product.isOutOfStock)
                    AppStatusChip.outOfStock()
                  else if (!isGridCard && isHighlightedLowStock)
                    AppStatusChip.lowStock(),
                ],
              ),
              SizedBox(height: 14.h),
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
              if (!enableCardTapToAdd) ...<Widget>[
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onAdd,
                    child: Text(
                      product.isOutOfStock
                          ? 'Tidak bisa dijual'
                          : 'Tambah ke cart',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isGridCard && quantityInCart <= 0 && product.isOutOfStock)
          Positioned(top: 10, right: 10, child: AppStatusChip.outOfStock())
        else if (isGridCard && quantityInCart <= 0 && isHighlightedLowStock)
          Positioned(top: 10, right: 10, child: AppStatusChip.lowStock()),
        if (isGridCard && quantityInCart > 0)
          Positioned(
            top: 10,
            right: 10,
            child: _CartCountBadge(count: quantityInCart),
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
          borderRadius: BorderRadius.circular(22.r),
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
            borderRadius: BorderRadius.circular(20.r),
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
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
                  SizedBox(height: 4.h),
                  Text(
                    '${state.totalItems} item • ${_formatCurrency(state.totalAmount)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
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
            ),
            SizedBox(height: 12.h),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: state.items.length,
                separatorBuilder: (_, _) => SizedBox(height: 8.h),
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
            SizedBox(height: 12.h),
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
            SizedBox(height: 12.h),
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
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
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: theme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formatCurrency(item.subtotal),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 18),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
          SizedBox(height: 8.h),
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

class _CartCountBadge extends StatelessWidget {
  const _CartCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xFF14B88F),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: foregroundColor),
          SizedBox(width: 6.w),
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
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8.h),
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
