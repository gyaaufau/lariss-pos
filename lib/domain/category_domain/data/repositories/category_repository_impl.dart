import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._localDatasource);

  final CategoryLocalDatasource _localDatasource;

  @override
  Future<Either<Failure, CategoryEntity>> createCategory(String name) async {
    try {
      final trimmedName = name.trim();

      if (trimmedName.isEmpty) {
        return left(Failure('Nama kategori wajib diisi.'));
      }

      final category = await _localDatasource.createCategory(trimmedName);

      return right(category);
    } catch (_) {
      return left(Failure('Gagal membuat kategori.'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await _localDatasource.getCategories();

      return right(categories);
    } catch (_) {
      return left(Failure('Gagal memuat kategori.'));
    }
  }
}
