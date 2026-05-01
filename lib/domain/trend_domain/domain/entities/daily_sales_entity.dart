class DailySalesEntity {
  const DailySalesEntity({
    required this.label,
    required this.totalSales,
    required this.totalTransactions,
  });

  final String label;
  final int totalSales;
  final int totalTransactions;
}
