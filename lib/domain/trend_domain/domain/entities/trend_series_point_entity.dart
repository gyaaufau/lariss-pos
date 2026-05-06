class TrendSeriesPointEntity {
  const TrendSeriesPointEntity({
    required this.label,
    required this.shortLabel,
    required this.startAt,
    required this.endAt,
    required this.totalSales,
    required this.totalTransactions,
  });

  final String label;
  final String shortLabel;
  final int startAt;
  final int endAt;
  final int totalSales;
  final int totalTransactions;
}
