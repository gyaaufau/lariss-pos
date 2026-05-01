import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/store_profile_entity.dart';
import '../repositories/profile_repository.dart';

class SaveStoreProfile {
  const SaveStoreProfile(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, StoreProfileEntity>> call({
    required String storeName,
    required String ownerName,
  }) {
    return _repository.saveStoreProfile(
      storeName: storeName,
      ownerName: ownerName,
    );
  }
}
