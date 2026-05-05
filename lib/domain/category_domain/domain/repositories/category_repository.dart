import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, CategoryEntity>> getCategoryById(String id);

  Future<Either<Failure, CategoryEntity>> createCategory(String name);

  Future<Either<Failure, CategoryEntity>> updateCategory({
    required String id,
    required String name,
    required int createdAt,
  });

  Future<Either<Failure, void>> deleteCategory(String id);
}
