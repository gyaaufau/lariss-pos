import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/tokens/app_design_token.dart';
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

  List<_MovementGroup> _groupMovementsByDate(
    List<StockMovementEntity> movements,
  ) {
    final Map<String, List<StockMovementEntity>> grouped =
        <String, List<StockMovementEntity>>{};
    final List<String> orderedKeys = <String>[];

    for (final movement in movements) {
      final date = DateTime.fromMillisecondsSinceEpoch(movement.createdAt);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final key =
          '${normalizedDate.year}-${normalizedDate.month}-${normalizedDate.day}';

      if (!grouped.containsKey(key)) {
        grouped[key] = <StockMovementEntity>[];
        orderedKeys.add(key);
      }

      grouped[key]!.add(movement);
    }

    return orderedKeys
        .map(
          (key) => _MovementGroup(
            label: _formatGroupDate(grouped[key]!.first.createdAt),
            movements: grouped[key]!,
          ),
        )
        .toList();
  }

  String _formatGroupDate(int epochMs) {
    const monthNames = <String>[
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final date = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
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
          final groupedMovements = _groupMovementsByDate(state.movements);
          if (product == null) {
            return const Center(child: Text('Produk stok tidak ditemukan.'));
          }

          return SafeArea(
            child: ListView(
              padding: AppDesignToken.cardPadding,
              children: <Widget>[
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: AppDesignToken.cardTitleGap),
                      _InfoRow(
                        label: 'Stok sekarang',
                        value: '${product.currentStock}',
                      ),
                      SizedBox(height: AppDesignToken.infoRowGap),
                      _InfoRow(
                        label: 'Minimum stok',
                        value: '${product.minimumStock}',
                      ),
                      SizedBox(height: AppDesignToken.infoRowGap),
                      _InfoRow(
                        label: 'Harga jual',
                        value: formatCurrency(product.sellingPrice),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDesignToken.sectionGap),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openUpdate,
                    icon: const Icon(Icons.sync_alt),
                    label: const Text('Update stok'),
                  ),
                ),
                SizedBox(height: AppDesignToken.movementGroupGap),
                Text(
                  'Riwayat perubahan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                  SizedBox(height: AppDesignToken.infoRowGap),
                  if (state.movements.isEmpty)
                  const _EmptyMovementState()
                else
                  ...groupedMovements.map(
                    (group) => Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            group.label,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF475569),
                                ),
                          ),
                          SizedBox(height: AppDesignToken.subtitleContentGap),
                          ...group.movements.map(
                            (movement) => Padding(
                              padding: EdgeInsets.only(bottom: AppDesignToken.itemGap),
                              child: _Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _movementLabel(movement),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    SizedBox(height: AppDesignToken.infoRowGap),
                                    _InfoRow(
                                      label: 'Jumlah',
                                      value: '${movement.quantity}',
                                    ),
                                    SizedBox(height: AppDesignToken.infoRowGap),
                                    _InfoRow(
                                      label: 'Sebelum',
                                      value: '${movement.stockBefore}',
                                    ),
                                    SizedBox(height: AppDesignToken.infoRowGap),
                                    _InfoRow(
                                      label: 'Sesudah',
                                      value: '${movement.stockAfter}',
                                    ),
                                    SizedBox(height: AppDesignToken.infoRowGap),
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

class _MovementGroup {
  const _MovementGroup({required this.label, required this.movements});

  final String label;
  final List<StockMovementEntity> movements;
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDesignToken.cardPadding.top + 4.r),
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
        SizedBox(width: AppDesignToken.movementGroupGap),
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
      padding: EdgeInsets.all(AppDesignToken.cardPadding.top + 4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        'Belum ada riwayat perubahan stok untuk produk ini.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
