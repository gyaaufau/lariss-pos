import '../../../../core/database/daos/products_dao.dart';
import '../models/product_model.dart';
import 'product_local_datasource.dart';

class ProductLocalDatasourceImpl implements ProductLocalDatasource {
  const ProductLocalDatasourceImpl(this._productsDao);

  final ProductsDao _productsDao;

  @override
  Future<ProductModel> createProduct({
    required String categoryId,
    required String name,
    required int sellingPrice,
    required int currentStock,
    required int minimumStock,
    required bool isActive,
  }) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final ProductModel product = ProductModel(
      id: 'prd_$now',
      categoryId: categoryId,
      name: name,
      sellingPrice: sellingPrice,
      currentStock: currentStock,
      minimumStock: minimumStock,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );

    await _productsDao.upsertProduct(product.toCompanion());

    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    final existing = await _productsDao.getById(id);

    if (existing == null) {
      return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final ProductModel deletedProduct = ProductModel.fromTableData(
      existing,
    ).copyWith(updatedAt: now, deletedAt: now);

    await _productsDao.upsertProduct(deletedProduct.toCompanion());
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    final products = await _productsDao.getAll();

    return products.map(ProductModel.fromTableData).toList(growable: false);
  }

  @override
  Future<ProductModel> updateProduct({
    required String id,
    required String categoryId,
    required String name,
    required int sellingPrice,
    required int currentStock,
    required int minimumStock,
    required bool isActive,
    required int createdAt,
  }) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final ProductModel product = ProductModel(
      id: id,
      categoryId: categoryId,
      name: name,
      sellingPrice: sellingPrice,
      currentStock: currentStock,
      minimumStock: minimumStock,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: now,
    );

    await _productsDao.upsertProduct(product.toCompanion());

    return product;
  }
}
