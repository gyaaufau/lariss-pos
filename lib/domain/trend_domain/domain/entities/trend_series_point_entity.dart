class TrendSeriesPointEntity {
  const TrendSeriesPointEntity({
    required this.label,
    required this.shortLabel,
    required this.totalSales,
    required this.totalTransactions,
  });

  final String label;
  final String shortLabel;
  final int totalSales;
  final int totalTransactions;
}
