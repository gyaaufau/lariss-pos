import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/store_profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetStoreProfile {
  const GetStoreProfile(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, StoreProfileEntity>> call() {
    return _repository.getStoreProfile();
  }
}
