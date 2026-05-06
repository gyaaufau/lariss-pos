import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/app_settings_entity.dart';
import '../repositories/profile_repository.dart';

class SaveAppSettings {
  const SaveAppSettings(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, AppSettingsEntity>> call({
    required bool lowStockAlertEnabled,
    required bool onboardingCompleted,
  }) {
    return _repository.saveAppSettings(
      lowStockAlertEnabled: lowStockAlertEnabled,
      onboardingCompleted: onboardingCompleted,
    );
  }
}
