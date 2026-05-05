import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/category_repository.dart';

class DeleteCategory {
  const DeleteCategory(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteCategory(id);
  }
}
