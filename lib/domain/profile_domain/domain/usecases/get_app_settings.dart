import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/app_settings_entity.dart';
import '../repositories/profile_repository.dart';

class GetAppSettings {
  const GetAppSettings(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, AppSettingsEntity>> call() {
    return _repository.getAppSettings();
  }
}
