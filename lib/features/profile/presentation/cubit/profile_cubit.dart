import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/profile_domain/domain/usecases/get_app_settings.dart';
import '../../../../domain/profile_domain/domain/usecases/get_store_profile.dart';
import '../../../../domain/profile_domain/domain/usecases/save_app_settings.dart';
import '../../../../domain/profile_domain/domain/usecases/save_store_profile.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetStoreProfile getStoreProfile,
    required SaveStoreProfile saveStoreProfile,
    required GetAppSettings getAppSettings,
    required SaveAppSettings saveAppSettings,
  }) : _getStoreProfile = getStoreProfile,
       _saveStoreProfile = saveStoreProfile,
       _getAppSettings = getAppSettings,
       _saveAppSettings = saveAppSettings,
       super(const ProfileState());

  final GetStoreProfile _getStoreProfile;
  final SaveStoreProfile _saveStoreProfile;
  final GetAppSettings _getAppSettings;
  final SaveAppSettings _saveAppSettings;

  Future<void> loadProfile() async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final profileResult = await _getStoreProfile();
    final settingsResult = await _getAppSettings();

    profileResult.match(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
          clearSuccessMessage: true,
        ),
      ),
      (profile) => settingsResult.match(
        (failure) => emit(
          state.copyWith(
            status: ProfileStatus.failure,
            profile: profile,
            errorMessage: failure.message,
            clearSuccessMessage: true,
          ),
        ),
        (settings) => emit(
          state.copyWith(
            status: ProfileStatus.success,
            profile: profile,
            settings: settings,
            clearErrorMessage: true,
            clearSuccessMessage: true,
          ),
        ),
      ),
    );
  }

  void updateSettingsDraft({
    bool? lowStockAlertEnabled,
    bool? showOutOfStockProducts,
  }) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(
          lowStockAlertEnabled: lowStockAlertEnabled,
          showOutOfStockProducts: showOutOfStockProducts,
        ),
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );
  }

  Future<bool> saveProfile({
    required String storeName,
    required String ownerName,
  }) async {
    emit(
      state.copyWith(
        status: ProfileStatus.submitting,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final profileResult = await _saveStoreProfile(
      storeName: storeName,
      ownerName: ownerName,
    );

    return await profileResult.match(
      (failure) async {
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.message,
            clearSuccessMessage: true,
          ),
        );
        return false;
      },
      (profile) async {
        final settingsResult = await _saveAppSettings(
          lowStockAlertEnabled: state.settings.lowStockAlertEnabled,
          showOutOfStockProducts: state.settings.showOutOfStockProducts,
        );

        return settingsResult.match(
          (failure) {
            emit(
              state.copyWith(
                status: ProfileStatus.failure,
                profile: profile,
                errorMessage: failure.message,
                clearSuccessMessage: true,
              ),
            );
            return false;
          },
          (settings) {
            emit(
              state.copyWith(
                status: ProfileStatus.success,
                profile: profile,
                settings: settings,
                successMessage: 'Profile dan settings berhasil disimpan.',
                clearErrorMessage: true,
              ),
            );
            return true;
          },
        );
      },
    );
  }

  void clearFeedback() {
    emit(state.copyWith(clearErrorMessage: true, clearSuccessMessage: true));
  }
}
