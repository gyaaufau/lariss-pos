import '../../../../core/database/daos/transactions_dao.dart';
import '../../domain/entities/trend_date_filter_entity.dart';
import '../../domain/entities/trend_range.dart';
import '../models/trend_dashboard_model.dart';
import '../../../transaction_domain/data/models/transaction_item_model.dart';
import '../../../transaction_domain/data/models/transaction_model.dart';
import '../services/trend_dashboard_aggregator.dart';
import 'trend_local_datasource.dart';

class TrendLocalDatasourceImpl implements TrendLocalDatasource {
  TrendLocalDatasourceImpl(
    this._transactionsDao, {
    TrendDashboardAggregator? aggregator,
    DateTime Function()? nowProvider,
  }) : _aggregator = aggregator ?? TrendDashboardAggregator(),
       _nowProvider = nowProvider ?? DateTime.now;

  final TransactionsDao _transactionsDao;
  final TrendDashboardAggregator _aggregator;
  final DateTime Function() _nowProvider;

  @override
  Future<TrendDashboardModel> getTrendDashboard(
    TrendRange range, {
    TrendDateFilterEntity? filter,
  }) async {
    final transactions = await _transactionsDao.getAll();
    final items = await _transactionsDao.getAllItems();

    if (transactions.isEmpty) {
      return TrendDashboardModel.empty(range);
    }

    return _aggregator.build(
      range: range,
      filter: filter,
      transactions: transactions
          .map(TransactionModel.fromTableData)
          .toList(growable: false),
      items: items
          .map(TransactionItemModel.fromTableData)
          .toList(growable: false),
      now: _nowProvider(),
    );
  }
}
