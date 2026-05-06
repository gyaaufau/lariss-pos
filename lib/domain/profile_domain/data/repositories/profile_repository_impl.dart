import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/entities/store_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._localDatasource);

  final ProfileLocalDatasource _localDatasource;

  @override
  Future<Either<Failure, AppSettingsEntity>> getAppSettings() async {
    try {
      final settings = await _localDatasource.getAppSettings();
      return right(settings);
    } catch (_) {
      return left(Failure('Gagal memuat settings aplikasi.'));
    }
  }

  @override
  Future<Either<Failure, StoreProfileEntity>> getStoreProfile() async {
    try {
      final profile = await _localDatasource.getStoreProfile();
      return right(profile);
    } catch (_) {
      return left(Failure('Gagal memuat profile toko.'));
    }
  }

  @override
  Future<Either<Failure, AppSettingsEntity>> saveAppSettings({
    required bool lowStockAlertEnabled,
    required bool onboardingCompleted,
  }) async {
    try {
      final settings = await _localDatasource.saveAppSettings(
        lowStockAlertEnabled: lowStockAlertEnabled,
        onboardingCompleted: onboardingCompleted,
      );
      return right(settings);
    } catch (_) {
      return left(Failure('Gagal menyimpan settings aplikasi.'));
    }
  }

  @override
  Future<Either<Failure, StoreProfileEntity>> saveStoreProfile({
    required String storeName,
    required String ownerName,
  }) async {
    try {
      final String trimmedStoreName = storeName.trim();
      final String trimmedOwnerName = ownerName.trim();

      if (trimmedStoreName.isEmpty) {
        return left(Failure('Nama toko wajib diisi.'));
      }

      if (trimmedOwnerName.isEmpty) {
        return left(Failure('Nama owner wajib diisi.'));
      }

      final profile = await _localDatasource.saveStoreProfile(
        storeName: trimmedStoreName,
        ownerName: trimmedOwnerName,
      );
      return right(profile);
    } catch (_) {
      return left(Failure('Gagal menyimpan profile toko.'));
    }
  }
}
