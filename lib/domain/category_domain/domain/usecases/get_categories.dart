import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, List<CategoryEntity>>> call() {
    return _repository.getCategories();
  }
}
