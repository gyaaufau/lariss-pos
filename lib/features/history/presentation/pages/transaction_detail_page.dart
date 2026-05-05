import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../domain/transaction_domain/domain/entities/transaction_entity.dart';
import '../../../../domain/transaction_domain/domain/entities/transaction_item_entity.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({
    required this.transactionId,
    this.initialTransaction,
    super.key,
  });

  final String transactionId;
  final TransactionEntity? initialTransaction;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  TransactionEntity? _transaction;

  @override
  void initState() {
    super.initState();
    _transaction = widget.initialTransaction;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetail();
    });
  }

  Future<void> _loadDetail() async {
    final detail = await context.read<HistoryCubit>().getDetail(
      widget.transactionId,
    );
    if (!mounted || detail == null) {
      return;
    }

    setState(() {
      _transaction = detail;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transaction = _transaction;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail invoice')),
      body: BlocConsumer<HistoryCubit, HistoryState>(
        listener: (context, state) {
          if (state.status == HistoryStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final isLoading = state.status == HistoryStatus.loadingDetail;

          if (transaction == null && isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (transaction == null) {
            return const Center(child: Text('Detail invoice tidak ditemukan.'));
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadDetail,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  if (isLoading) ...<Widget>[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 16),
                  ],
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          transaction.invoiceNumber,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatDateTime(transaction.createdAt),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _HighlightMetric(
                                label: 'Total item',
                                value: '${transaction.totalItem}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _HighlightMetric(
                                label: 'Total',
                                value: formatCurrency(transaction.totalAmount),
                                valueColor: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Item belanja',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (transaction.items.isEmpty)
                    const _EmptyItemsCard()
                  else
                    ...transaction.items.map(
                      (TransactionItemEntity item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SectionCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      item.productName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${item.quantity} x ${formatCurrency(item.productPrice)}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                formatCurrency(item.subtotal),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Ringkasan pembayaran',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    child: Column(
                      children: <Widget>[
                        _InfoRow(
                          label: 'Total transaksi',
                          value: formatCurrency(transaction.totalAmount),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Nominal dibayar',
                          value: formatCurrency(transaction.paidAmount),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Kembalian',
                          value: formatCurrency(transaction.changeAmount),
                          valueColor: const Color(0xFF166534),
                        ),
                      ],
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

class _HighlightMetric extends StatelessWidget {
  const _HighlightMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(label)),
        const SizedBox(width: 16),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}

class _EmptyItemsCard extends StatelessWidget {
  const _EmptyItemsCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      child: Text('Belum ada item detail untuk transaksi ini.'),
    );
  }
}
