import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoryById {
  const GetCategoryById(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, CategoryEntity>> call(String id) {
    return _repository.getCategoryById(id);
  }
}
