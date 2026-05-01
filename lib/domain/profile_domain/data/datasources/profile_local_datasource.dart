import '../models/app_settings_model.dart';
import '../models/store_profile_model.dart';

abstract class ProfileLocalDatasource {
  Future<StoreProfileModel> getStoreProfile();

  Future<StoreProfileModel> saveStoreProfile({
    required String storeName,
    required String ownerName,
  });

  Future<AppSettingsModel> getAppSettings();

  Future<AppSettingsModel> saveAppSettings({
    required bool lowStockAlertEnabled,
    required bool showOutOfStockProducts,
  });
}
