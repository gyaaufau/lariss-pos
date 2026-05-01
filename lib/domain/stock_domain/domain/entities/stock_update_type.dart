enum StockUpdateType {
  stockIn('in', 'Stock in'),
  stockOut('out', 'Stock out'),
  adjustment('adjustment', 'Adjustment');

  const StockUpdateType(this.value, this.label);

  final String value;
  final String label;
}
