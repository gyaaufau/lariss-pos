import '../../domain/entities/daily_sales_entity.dart';

class DailySalesModel extends DailySalesEntity {
  const DailySalesModel({
    required super.label,
    required super.totalSales,
    required super.totalTransactions,
  });
}
