import '../../../../domain/profile_domain/domain/entities/app_settings_entity.dart';
import '../../../../domain/profile_domain/domain/entities/store_profile_entity.dart';

enum ProfileStatus { initial, loading, success, failure, submitting }

class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.settings = const AppSettingsEntity(
      lowStockAlertEnabled: true,
      onboardingCompleted: false,
    ),
    this.errorMessage,
    this.successMessage,
  });

  final ProfileStatus status;
  final StoreProfileEntity? profile;
  final AppSettingsEntity settings;
  final String? errorMessage;
  final String? successMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    StoreProfileEntity? profile,
    AppSettingsEntity? settings,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}
