import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class UpdateCategory {
  const UpdateCategory(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, CategoryEntity>> call(UpdateCategoryParams params) {
    return _repository.updateCategory(
      id: params.id,
      name: params.name,
      createdAt: params.createdAt,
    );
  }
}

class UpdateCategoryParams {
  const UpdateCategoryParams({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int createdAt;
}
