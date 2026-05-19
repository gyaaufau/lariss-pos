import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/tokens/app_design_token.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../profile/presentation/cubit/app_settings_cubit.dart';
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
          final bool showLowStockAlert = context
              .watch<AppSettingsCubit>()
              .state
              .settings
              .lowStockAlertEnabled;
          final bool isLoading =
              state.status == StockStatus.loading && state.products.isEmpty;

          return SafeArea(
            child: Padding(
              padding: AppDesignToken.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Text(
                  //   'Pantau dan ubah stok produk.',
                  //   style: Theme.of(context).textTheme.headlineSmall,
                  // ),
                  // SizedBox(height: AppDesignToken.infoRowGap),
                  // Text(
                  //   'Detail stok dan update sekarang dibuka di layar terpisah.',
                  //   style: Theme.of(context).textTheme.bodyMedium,
                  // ),
                  // SizedBox(height: AppDesignToken.subtitleContentGap),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _SummaryCard(
                          title: 'Produk aktif',
                          value: '${state.products.length}',
                        ),
                      ),
                      if (showLowStockAlert) ...<Widget>[
                        SizedBox(width: AppDesignToken.infoRowGap * 1.5),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Stok menipis',
                            value: '${state.lowStockProducts.length}',
                            accentColor: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppDesignToken.subtitleContentGap),
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
                                  SizedBox(height: AppDesignToken.itemGap),
                              itemBuilder: (context, index) {
                                final product = state.products[index];
                                return _StockProductCard(
                                  name: product.name,
                                  stock: product.currentStock,
                                  minimumStock: product.minimumStock,
                                  isLowStock: product.isLowStock,
                                  showLowStockAlert: showLowStockAlert,
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
      padding: AppDesignToken.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: AppDesignToken.infoRowGap),
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
    required this.showLowStockAlert,
    required this.isOutOfStock,
    required this.onTap,
  });

  final String name;
  final int stock;
  final int minimumStock;
  final bool isLowStock;
  final bool showLowStockAlert;
  final bool isOutOfStock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: AppDesignToken.cardPadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: AppDesignToken.infoRowGap),
                    Text('Stok $stock • Minimum $minimumStock'),
                  ],
                ),
              ),
              SizedBox(width: AppDesignToken.infoRowGap * 1.5),
              isOutOfStock
                  ? AppStatusChip.outOfStock()
                  : isLowStock && showLowStockAlert
                  ? AppStatusChip.lowStock()
                  : AppStatusChip.safe(),
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
      padding: EdgeInsets.all(AppDesignToken.cardPadding.top * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Belum ada produk aktif.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppDesignToken.infoRowGap),
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
