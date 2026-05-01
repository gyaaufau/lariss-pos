// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dao.dart';

// ignore_for_file: type=lint
mixin _$ProfileDaoMixin on DatabaseAccessor<AppDatabase> {
  $StoreProfileTableTable get storeProfileTable =>
      attachedDatabase.storeProfileTable;
  $AppSettingsTableTable get appSettingsTable =>
      attachedDatabase.appSettingsTable;
  ProfileDaoManager get managers => ProfileDaoManager(this);
}

class ProfileDaoManager {
  final _$ProfileDaoMixin _db;
  ProfileDaoManager(this._db);
  $$StoreProfileTableTableTableManager get storeProfileTable =>
      $$StoreProfileTableTableTableManager(
        _db.attachedDatabase,
        _db.storeProfileTable,
      );
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(
        _db.attachedDatabase,
        _db.appSettingsTable,
      );
}
