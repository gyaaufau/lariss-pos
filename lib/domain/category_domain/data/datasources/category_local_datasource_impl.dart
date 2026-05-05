import '../../../../core/database/daos/categories_dao.dart';
import '../../../../core/database/daos/products_dao.dart';
import '../models/category_model.dart';
import 'category_local_datasource.dart';

class CategoryLocalDatasourceImpl implements CategoryLocalDatasource {
  const CategoryLocalDatasourceImpl(this._categoriesDao, this._productsDao);

  final CategoriesDao _categoriesDao;
  final ProductsDao _productsDao;

  @override
  Future<CategoryModel> createCategory(String name) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final CategoryModel category = CategoryModel(
      id: 'cat_$now',
      name: name,
      createdAt: now,
      updatedAt: now,
    );

    await _categoriesDao.upsertCategory(category.toCompanion());

    return category;
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final categories = await _categoriesDao.getAll();

    return categories.map(CategoryModel.fromTableData).toList(growable: false);
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    final category = await _categoriesDao.getById(id);
    if (category == null) {
      return null;
    }

    return CategoryModel.fromTableData(category);
  }

  @override
  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
    required int createdAt,
  }) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final CategoryModel category = CategoryModel(
      id: id,
      name: name,
      createdAt: createdAt,
      updatedAt: now,
    );

    await _categoriesDao.upsertCategory(category.toCompanion());

    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    final existing = await _categoriesDao.getById(id);
    if (existing == null) {
      return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final CategoryModel category = CategoryModel.fromTableData(
      existing,
    ).copyWith(updatedAt: now, deletedAt: now);

    await _categoriesDao.upsertCategory(category.toCompanion());
  }

  @override
  Future<int> getActiveProductCount(String categoryId) {
    return _productsDao.countByCategoryId(categoryId);
  }
}
