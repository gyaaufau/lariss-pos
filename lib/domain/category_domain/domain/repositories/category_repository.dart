import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, CategoryEntity>> createCategory(String name);
}
