import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/store_profile_entity.dart';

class StoreProfileModel extends StoreProfileEntity {
  const StoreProfileModel({
    required super.id,
    required super.storeName,
    required super.ownerName,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StoreProfileModel.fromTableData(StoreProfileTableData data) {
    return StoreProfileModel(
      id: data.id,
      storeName: data.storeName,
      ownerName: data.ownerName,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  StoreProfileTableCompanion toCompanion() {
    return StoreProfileTableCompanion(
      id: Value(id),
      storeName: Value(storeName),
      ownerName: Value(ownerName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
