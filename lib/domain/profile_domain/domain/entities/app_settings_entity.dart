class AppSettingsEntity {
  const AppSettingsEntity({
    required this.lowStockAlertEnabled,
    required this.onboardingCompleted,
  });

  final bool lowStockAlertEnabled;
  final bool onboardingCompleted;

  AppSettingsEntity copyWith({
    bool? lowStockAlertEnabled,
    bool? onboardingCompleted,
  }) {
    return AppSettingsEntity(
      lowStockAlertEnabled: lowStockAlertEnabled ?? this.lowStockAlertEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
