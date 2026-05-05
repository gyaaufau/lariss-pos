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
      final String trimmedName = name.trim();
      final Failure? validation = _validateName(trimmedName);
      if (validation != null) {
        return left(validation);
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

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id) async {
    try {
      if (id.trim().isEmpty) {
        return left(Failure('Kategori tidak valid.'));
      }

      final category = await _localDatasource.getCategoryById(id);
      if (category == null) {
        return left(Failure('Kategori tidak ditemukan.'));
      }

      return right(category);
    } catch (_) {
      return left(Failure('Gagal memuat detail kategori.'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory({
    required String id,
    required String name,
    required int createdAt,
  }) async {
    try {
      if (id.trim().isEmpty) {
        return left(Failure('Kategori tidak valid.'));
      }

      final String trimmedName = name.trim();
      final Failure? validation = _validateName(trimmedName);
      if (validation != null) {
        return left(validation);
      }

      final category = await _localDatasource.updateCategory(
        id: id,
        name: trimmedName,
        createdAt: createdAt,
      );

      return right(category);
    } catch (_) {
      return left(Failure('Gagal memperbarui kategori.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      if (id.trim().isEmpty) {
        return left(Failure('Kategori tidak valid.'));
      }

      final int linkedProducts = await _localDatasource.getActiveProductCount(
        id,
      );
      if (linkedProducts > 0) {
        return left(
          Failure(
            'Kategori masih dipakai $linkedProducts produk. Hapus atau pindahkan produknya dulu.',
          ),
        );
      }

      await _localDatasource.deleteCategory(id);
      return right(null);
    } catch (_) {
      return left(Failure('Gagal menghapus kategori.'));
    }
  }

  Failure? _validateName(String name) {
    if (name.isEmpty) {
      return Failure('Nama kategori wajib diisi.');
    }

    return null;
  }
}
