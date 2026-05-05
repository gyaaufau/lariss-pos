import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/cart_domain/domain/entities/cart_item_entity.dart';
import '../../../../domain/transaction_domain/domain/entities/transaction_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../cart/presentation/cubit/checkout_cubit.dart';
import '../../../cart/presentation/cubit/checkout_state.dart';
import '../../../product/presentation/cubit/product_cubit.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final TextEditingController _paidAmountController;

  @override
  void initState() {
    super.initState();
    _paidAmountController = TextEditingController(
      text: context.read<CartCubit>().state.totalAmount.toString(),
    );
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    super.dispose();
  }

  Future<void> _submit(CartState cartState) async {
    final int? paidAmount = int.tryParse(_paidAmountController.text.trim());

    if (paidAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal pembayaran yang valid.'),
        ),
      );
      return;
    }

    final TransactionEntity? transaction = await context
        .read<CheckoutCubit>()
        .checkout(items: cartState.items, paidAmount: paidAmount);

    if (!mounted || transaction == null) {
      return;
    }

    context.read<CartCubit>().clearCart();
    await context.read<ProductCubit>().loadProducts();

    if (!mounted) {
      return;
    }

    context.read<CheckoutCubit>().reset();
    context.go(AppRouter.checkoutSuccessPath, extra: transaction);
  }

  @override
  Widget build(BuildContext context) {
    final CartState cartState = context.watch<CartCubit>().state;
    final int changePreview =
        (int.tryParse(_paidAmountController.text.trim()) ?? 0) -
        cartState.totalAmount;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state.status == CheckoutStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final bool isSubmitting = state.status == CheckoutStatus.submitting;

          return SafeArea(
            child: cartState.isEmpty
                ? const _EmptyCheckoutState()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      Text(
                        'Review belanja dan selesaikan pembayaran.',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Day 9 fokus: input pembayaran, ringkasan belanja, dan layar sukses setelah invoice tersimpan.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Ringkasan item',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            ...cartState.items.map(
                              (CartItemEntity item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _CheckoutItemTile(item: item),
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: 'Total item',
                              value: '${cartState.totalItems}',
                            ),
                            _SummaryRow(
                              label: 'Total bayar',
                              value: formatCurrency(cartState.totalAmount),
                              highlight: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Pembayaran',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _paidAmountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Nominal dibayar',
                                hintText: 'Contoh: 50000',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 12),
                            _SummaryRow(
                              label: 'Kembalian',
                              value: changePreview < 0
                                  ? 'Kurang ${formatCurrency(changePreview.abs())}'
                                  : formatCurrency(changePreview),
                              valueColor: changePreview < 0
                                  ? const Color(0xFFB91C1C)
                                  : const Color(0xFF166534),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => _submit(cartState),
                                child: Text(
                                  isSubmitting
                                      ? 'Memproses...'
                                      : 'Simpan transaksi',
                                ),
                              ),
                            ),
                          ],
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

class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({required this.transaction, super.key});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Sukses'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF166534),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Transaksi berhasil disimpan.',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transaction.invoiceNumber,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    _SummaryRow(
                      label: 'Total',
                      value: formatCurrency(transaction.totalAmount),
                    ),
                    _SummaryRow(
                      label: 'Dibayar',
                      value: formatCurrency(transaction.paidAmount),
                    ),
                    _SummaryRow(
                      label: 'Kembalian',
                      value: formatCurrency(transaction.changeAmount),
                      valueColor: const Color(0xFF166534),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(AppRouter.homePath),
                  child: const Text('Kembali ke kasir'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(
                    AppRouter.historyDetailPath(transaction.id),
                    extra: transaction,
                  ),
                  child: const Text('Lihat detail invoice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  const _CheckoutItemTile({required this.item});

  final CartItemEntity item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.productName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '${item.quantity} x ${formatCurrency(item.price)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(formatCurrency(item.subtotal)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool highlight;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style =
        (highlight
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.bodyLarge)
            ?.copyWith(color: valueColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _EmptyCheckoutState extends StatelessWidget {
  const _EmptyCheckoutState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.shopping_cart_checkout_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Cart masih kosong.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Balik ke halaman kasir lalu tambahkan produk dulu.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
