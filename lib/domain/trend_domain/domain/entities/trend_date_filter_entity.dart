class TrendDateFilterEntity {
  const TrendDateFilterEntity({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  String get cacheKey =>
      '${start.year}-${start.month}-${start.day}_${end.year}-${end.month}-${end.day}';
}
