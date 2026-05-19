import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/tokens/app_design_token.dart';
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

  void _setPaidAmount(int value) {
    _paidAmountController.text = value.toString();
    setState(() {});
  }

  void _appendPaidAmount(String value) {
    final String current = _paidAmountController.text.trim();
    final String nextValue;

    if (current.isEmpty || current == '0') {
      nextValue = value == '000' ? '0' : value;
    } else {
      nextValue = '$current$value';
    }

    _setPaidAmount(int.tryParse(nextValue) ?? 0);
  }

  void _removeLastPaidAmountDigit() {
    final String current = _paidAmountController.text.trim();
    if (current.isEmpty || current == '0') {
      _setPaidAmount(0);
      return;
    }

    final String nextValue = current.length == 1
        ? '0'
        : current.substring(0, current.length - 1);
    _setPaidAmount(int.tryParse(nextValue) ?? 0);
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
                    padding: AppDesignToken.cardPadding,
                    children: <Widget>[
                      Text(
                        'Review belanja dan selesaikan pembayaran.',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: AppDesignToken.sectionGap),
                       Container(
                         padding: AppDesignToken.cardPadding,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Ringkasan item',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                             SizedBox(height: AppDesignToken.subtitleContentGap),
                            ...cartState.items.map(
                               (CartItemEntity item) => Padding(
                                 padding: EdgeInsets.only(bottom: AppDesignToken.itemGap),
                                child: _CheckoutItemTile(item: item),
                              ),
                            ),
                            const Divider(),
                             SizedBox(height: AppDesignToken.infoRowGap),
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
                      SizedBox(height: AppDesignToken.sectionGap),
                       Container(
                         padding: AppDesignToken.cardPadding,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Pembayaran',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                             SizedBox(height: AppDesignToken.subtitleContentGap),
                            TextField(
                              controller: _paidAmountController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Nominal dibayar',
                                hintText: 'Input dari numpad',
                              ),
                              onTapOutside: (_) =>
                                  FocusScope.of(context).unfocus(),
                            ),
                             SizedBox(height: AppDesignToken.movementGroupGap),
                            _CheckoutNumpad(
                              onDigitPressed: _appendPaidAmount,
                              onBackspacePressed: _removeLastPaidAmountDigit,
                              onClearPressed: () =>
                                  _setPaidAmount(cartState.totalAmount),
                            ),
                             SizedBox(height: AppDesignToken.subtitleContentGap),
                            _SummaryRow(
                              label: 'Kembalian',
                              value: changePreview < 0
                                  ? 'Kurang ${formatCurrency(changePreview.abs())}'
                                  : formatCurrency(changePreview),
                              valueColor: changePreview < 0
                                  ? const Color(0xFFB91C1C)
                                  : const Color(0xFF166534),
                            ),
                             SizedBox(height: AppDesignToken.movementGroupGap),
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

class _CheckoutNumpad extends StatelessWidget {
  const _CheckoutNumpad({
    required this.onDigitPressed,
    required this.onBackspacePressed,
    required this.onClearPressed,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onClearPressed;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.95,
      children: <Widget>[
        for (final String digit in <String>[
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '000',
          '0',
        ])
          _NumpadButton(label: digit, onPressed: () => onDigitPressed(digit)),
        _NumpadButton(
          label: 'Hapus',
          icon: Icons.backspace_outlined,
          onPressed: onBackspacePressed,
        ),
        _NumpadButton(
          label: 'Pas',
          icon: Icons.restart_alt_rounded,
          onPressed: onClearPressed,
          isPrimary: true,
        ),
      ],
    );
  }
}

class _NumpadButton extends StatelessWidget {
  const _NumpadButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: AppDesignToken.infoRowGap + 2.h),
        minimumSize: const Size(0, 48),
        backgroundColor: isPrimary
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        foregroundColor: isPrimary
            ? colorScheme.onPrimary
            : colorScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      child: icon == null
          ? Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 18.sp),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 16),
                 SizedBox(width: AppDesignToken.infoRowGap * 0.75),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(fontSize: 13.sp),
                  ),
                ),
              ],
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
           padding: AppDesignToken.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                 padding: EdgeInsets.all(AppDesignToken.cardPadding.top * 1.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF166534),
                        size: 28,
                      ),
                    ),
                    SizedBox(height: AppDesignToken.movementGroupGap),
                    Text(
                      'Transaksi berhasil disimpan.',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: AppDesignToken.infoRowGap),
                    Text(
                      transaction.invoiceNumber,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: AppDesignToken.sectionGap),
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
              SizedBox(height: AppDesignToken.subtitleContentGap),
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
               SizedBox(height: AppDesignToken.infoRowGap * 0.5),
              Text(
                '${item.quantity} x ${formatCurrency(item.price)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
           SizedBox(width: AppDesignToken.infoRowGap * 1.5),
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
       padding: EdgeInsets.only(bottom: AppDesignToken.infoRowGap),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          SizedBox(width: AppDesignToken.infoRowGap * 1.5),
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
        padding: EdgeInsets.all(AppDesignToken.cardPadding.top * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.shopping_cart_checkout_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: AppDesignToken.movementGroupGap),
            Text(
              'Cart masih kosong.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppDesignToken.infoRowGap),
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
