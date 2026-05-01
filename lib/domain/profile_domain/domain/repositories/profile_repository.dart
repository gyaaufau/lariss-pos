import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/app_settings_entity.dart';
import '../entities/store_profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, StoreProfileEntity>> getStoreProfile();

  Future<Either<Failure, StoreProfileEntity>> saveStoreProfile({
    required String storeName,
    required String ownerName,
  });

  Future<Either<Failure, AppSettingsEntity>> getAppSettings();

  Future<Either<Failure, AppSettingsEntity>> saveAppSettings({
    required bool lowStockAlertEnabled,
    required bool showOutOfStockProducts,
  });
}
