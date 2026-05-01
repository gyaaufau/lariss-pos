class AppSettingsEntity {
  const AppSettingsEntity({
    required this.lowStockAlertEnabled,
    required this.showOutOfStockProducts,
  });

  final bool lowStockAlertEnabled;
  final bool showOutOfStockProducts;

  AppSettingsEntity copyWith({
    bool? lowStockAlertEnabled,
    bool? showOutOfStockProducts,
  }) {
    return AppSettingsEntity(
      lowStockAlertEnabled: lowStockAlertEnabled ?? this.lowStockAlertEnabled,
      showOutOfStockProducts:
          showOutOfStockProducts ?? this.showOutOfStockProducts,
    );
  }
}
