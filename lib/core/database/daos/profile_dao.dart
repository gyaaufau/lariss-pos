import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/app_settings_table.dart';
import '../tables/store_profile_table.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: <Type>[StoreProfileTable, AppSettingsTable])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
  ProfileDao(super.attachedDatabase);

  Future<StoreProfileTableData?> getStoreProfile() {
    return select(storeProfileTable).getSingleOrNull();
  }

  Future<List<AppSettingsTableData>> getSettings() {
    return select(appSettingsTable).get();
  }

  Future<void> upsertStoreProfile(StoreProfileTableCompanion entry) async {
    await into(storeProfileTable).insertOnConflictUpdate(entry);
  }

  Future<void> upsertSetting(AppSettingsTableCompanion entry) async {
    await into(appSettingsTable).insertOnConflictUpdate(entry);
  }
}
