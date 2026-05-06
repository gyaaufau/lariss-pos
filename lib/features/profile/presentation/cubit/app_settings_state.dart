import '../../../../domain/profile_domain/domain/entities/app_settings_entity.dart';

enum AppSettingsStatus { initial, loading, success, failure }

class AppSettingsState {
  const AppSettingsState({
    this.status = AppSettingsStatus.initial,
    this.settings = const AppSettingsEntity(
      lowStockAlertEnabled: true,
      onboardingCompleted: false,
    ),
    this.errorMessage,
  });

  final AppSettingsStatus status;
  final AppSettingsEntity settings;
  final String? errorMessage;

  AppSettingsState copyWith({
    AppSettingsStatus? status,
    AppSettingsEntity? settings,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AppSettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
