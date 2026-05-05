String formatCurrency(int value) => 'Rp${formatNumber(value)}';

String formatCompactCurrency(int value) {
  final int absValue = value.abs();
  if (absValue >= 1000000) {
    final String text = (value / 1000000).toStringAsFixed(absValue >= 10000000 ? 0 : 1);
    return 'Rp${text}jt';
  }
  if (absValue >= 1000) {
    final String text = (value / 1000).toStringAsFixed(absValue >= 10000 ? 0 : 1);
    return 'Rp${text}rb';
  }
  return 'Rp$value';
}

String formatNumber(int value) {
  final String raw = value.abs().toString();
  final StringBuffer buffer = StringBuffer();

  for (int index = 0; index < raw.length; index++) {
    final int positionFromEnd = raw.length - index;
    buffer.write(raw[index]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }

  return value < 0 ? '-${buffer.toString()}' : buffer.toString();
}

String formatDateTime(int epochMs) {
  final date = DateTime.fromMillisecondsSinceEpoch(epochMs);
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}
