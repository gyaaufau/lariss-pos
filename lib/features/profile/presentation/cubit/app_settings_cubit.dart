import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/profile_domain/domain/entities/app_settings_entity.dart';
import '../../../../domain/profile_domain/domain/usecases/get_app_settings.dart';
import 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit({required GetAppSettings getAppSettings})
    : _getAppSettings = getAppSettings,
      super(const AppSettingsState());

  final GetAppSettings _getAppSettings;

  Future<void> loadSettings() async {
    emit(
      state.copyWith(
        status: AppSettingsStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final result = await _getAppSettings();
    result.match(
      (failure) => emit(
        state.copyWith(
          status: AppSettingsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (settings) => emit(
        state.copyWith(
          status: AppSettingsStatus.success,
          settings: settings,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  void syncSettings(AppSettingsEntity settings) {
    emit(
      state.copyWith(
        status: AppSettingsStatus.success,
        settings: settings,
        clearErrorMessage: true,
      ),
    );
  }
}
