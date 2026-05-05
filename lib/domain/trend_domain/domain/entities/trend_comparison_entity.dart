class TrendComparisonEntity {
  const TrendComparisonEntity({
    required this.currentValue,
    required this.previousValue,
  });

  final int currentValue;
  final int previousValue;

  int get delta => currentValue - previousValue;

  double? get changePercent {
    if (previousValue == 0) {
      return currentValue == 0 ? 0 : null;
    }
    return (delta / previousValue) * 100;
  }

  bool get isUp => delta > 0;
  bool get isDown => delta < 0;
}
