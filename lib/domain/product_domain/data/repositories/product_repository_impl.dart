import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._localDatasource);

  final ProductLocalDatasource _localDatasource;

  @override
  Future<Either<Failure, ProductEntity>> createProduct({
    required String categoryId,
    required String name,
    required int sellingPrice,
    required int currentStock,
    required int minimumStock,
    required bool isActive,
  }) async {
    try {
      final Failure? validation = _validatePayload(
        categoryId: categoryId,
        name: name,
        sellingPrice: sellingPrice,
        currentStock: currentStock,
        minimumStock: minimumStock,
      );

      if (validation != null) {
        return left(validation);
      }

      final product = await _localDatasource.createProduct(
        categoryId: categoryId,
        name: name.trim(),
        sellingPrice: sellingPrice,
        currentStock: currentStock,
        minimumStock: minimumStock,
        isActive: isActive,
      );

      return right(product);
    } catch (_) {
      return left(Failure('Gagal membuat produk.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      if (id.trim().isEmpty) {
        return left(Failure('Produk tidak valid.'));
      }

      await _localDatasource.deleteProduct(id);

      return right(null);
    } catch (_) {
      return left(Failure('Gagal menghapus produk.'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final products = await _localDatasource.getProducts();

      return right(products);
    } catch (_) {
      return left(Failure('Gagal memuat produk.'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct({
    required String id,
    required String categoryId,
    required String name,
    required int sellingPrice,
    required int currentStock,
    required int minimumStock,
    required bool isActive,
    required int createdAt,
  }) async {
    try {
      if (id.trim().isEmpty) {
        return left(Failure('Produk tidak valid.'));
      }

      final Failure? validation = _validatePayload(
        categoryId: categoryId,
        name: name,
        sellingPrice: sellingPrice,
        currentStock: currentStock,
        minimumStock: minimumStock,
      );

      if (validation != null) {
        return left(validation);
      }

      final product = await _localDatasource.updateProduct(
        id: id,
        categoryId: categoryId,
        name: name.trim(),
        sellingPrice: sellingPrice,
        currentStock: currentStock,
        minimumStock: minimumStock,
        isActive: isActive,
        createdAt: createdAt,
      );

      return right(product);
    } catch (_) {
      return left(Failure('Gagal memperbarui produk.'));
    }
  }

  Failure? _validatePayload({
    required String categoryId,
    required String name,
    required int sellingPrice,
    required int currentStock,
    required int minimumStock,
  }) {
    if (categoryId.trim().isEmpty) {
      return Failure('Kategori produk wajib dipilih.');
    }

    if (name.trim().isEmpty) {
      return Failure('Nama produk wajib diisi.');
    }

    if (sellingPrice < 0) {
      return Failure('Harga jual tidak boleh minus.');
    }

    if (currentStock < 0) {
      return Failure('Stok tidak boleh minus.');
    }

    if (minimumStock < 0) {
      return Failure('Minimum stok tidak boleh minus.');
    }

    return null;
  }
}
