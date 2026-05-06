import '../../../../core/database/daos/profile_dao.dart';
import '../models/app_settings_model.dart';
import '../models/store_profile_model.dart';
import 'profile_local_datasource.dart';

class ProfileLocalDatasourceImpl implements ProfileLocalDatasource {
  const ProfileLocalDatasourceImpl(this._profileDao);

  final ProfileDao _profileDao;

  static const String _storeProfileId = 'store_profile_main';

  @override
  Future<AppSettingsModel> getAppSettings() async {
    final rows = await _profileDao.getSettings();

    if (rows.isEmpty) {
      return const AppSettingsModel(
        lowStockAlertEnabled: true,
        onboardingCompleted: false,
      );
    }

    return AppSettingsModel.fromTableDataList(rows);
  }

  @override
  Future<StoreProfileModel> getStoreProfile() async {
    final existing = await _profileDao.getStoreProfile();
    if (existing != null) {
      return StoreProfileModel.fromTableData(existing);
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    return StoreProfileModel(
      id: _storeProfileId,
      storeName: 'Lariss POS',
      ownerName: 'Pemilik Toko',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<AppSettingsModel> saveAppSettings({
    required bool lowStockAlertEnabled,
    required bool onboardingCompleted,
  }) async {
    final List existingRows = await _profileDao.getSettings();
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int createdAt = existingRows.isEmpty
        ? now
        : existingRows.first.createdAt as int;
    final AppSettingsModel model = AppSettingsModel(
      lowStockAlertEnabled: lowStockAlertEnabled,
      onboardingCompleted: onboardingCompleted,
    );

    for (final entry in model.toCompanions(
      createdAt: createdAt,
      updatedAt: now,
    )) {
      await _profileDao.upsertSetting(entry);
    }

    return model;
  }

  @override
  Future<StoreProfileModel> saveStoreProfile({
    required String storeName,
    required String ownerName,
  }) async {
    final existing = await _profileDao.getStoreProfile();
    final int now = DateTime.now().millisecondsSinceEpoch;
    final StoreProfileModel model = StoreProfileModel(
      id: existing?.id ?? _storeProfileId,
      storeName: storeName,
      ownerName: ownerName,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await _profileDao.upsertStoreProfile(model.toCompanion());

    return model;
  }
}
