import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/tokens/app_design_token.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/transaction_domain/domain/entities/transaction_entity.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryCubit>().loadHistory();
    });
  }

  Future<void> _openDetail(TransactionEntity transaction) async {
    await context.push(
      AppRouter.historyDetailPath(transaction.id),
      extra: transaction,
    );
  }

  List<_HistoryGroup> _groupTransactionsByDate(
    List<TransactionEntity> transactions,
  ) {
    final Map<String, List<TransactionEntity>> grouped =
        <String, List<TransactionEntity>>{};
    final List<String> orderedKeys = <String>[];

    for (final transaction in transactions) {
      final date = DateTime.fromMillisecondsSinceEpoch(transaction.createdAt);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final key =
          '${normalizedDate.year}-${normalizedDate.month}-${normalizedDate.day}';

      if (!grouped.containsKey(key)) {
        grouped[key] = <TransactionEntity>[];
        orderedKeys.add(key);
      }

      grouped[key]!.add(transaction);
    }

    return orderedKeys
        .map(
          (key) => _HistoryGroup(
            label: _formatGroupDate(grouped[key]!.first.createdAt),
            transactions: grouped[key]!,
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
      appBar: AppBar(title: const Text('Riwayat transaksi')),
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
          final isLoading =
              state.status == HistoryStatus.loading &&
              state.transactions.isEmpty;
          final groupedTransactions = _groupTransactionsByDate(
            state.transactions,
          );

          return SafeArea(
            child: Padding(
              padding: AppDesignToken.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Semua invoice tersimpan lokal.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: AppDesignToken.sectionGap),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : state.transactions.isEmpty
                        ? const _EmptyHistoryState()
                        : RefreshIndicator(
                            onRefresh: () =>
                                context.read<HistoryCubit>().loadHistory(),
                            child: ListView.separated(
                              itemCount: groupedTransactions.length,
                              separatorBuilder: (_, _) =>
                                  SizedBox(height: AppDesignToken.sectionGap),
                              itemBuilder: (context, index) {
                                final group = groupedTransactions[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      group.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF475569),
                                          ),
                                    ),
                                    SizedBox(height: AppDesignToken.subtitleContentGap),
                                    Column(
                                      children: group.transactions
                                          .map(
                                            (transaction) => Padding(
                                              padding: EdgeInsets.only(
                                                bottom: AppDesignToken.itemGap,
                                              ),
                                              child: _TransactionCard(
                                                transaction: transaction,
                                                onTap: () =>
                                                    _openDetail(transaction),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
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

class _HistoryGroup {
  const _HistoryGroup({required this.label, required this.transactions});

  final String label;
  final List<TransactionEntity> transactions;
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction, required this.onTap});

  final TransactionEntity transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
           padding: EdgeInsets.all(AppDesignToken.cardPadding.top + 2.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      transaction.invoiceNumber,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    formatCurrency(transaction.totalAmount),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDesignToken.infoRowGap),
              Text(
                '${transaction.totalItem} item • ${formatDateTime(transaction.createdAt)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: AppDesignToken.subtitleContentGap),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Bayar ${formatCurrency(transaction.paidAmount)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDesignToken.cardPadding.top * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.receipt_long_outlined,
            size: 36,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: AppDesignToken.movementGroupGap),
          Text(
            'Belum ada riwayat transaksi.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppDesignToken.infoRowGap),
          Text(
            'Begitu checkout selesai dibuat, semua invoice akan tampil di sini lengkap dengan detail item.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
