import '../../../../core/database/daos/categories_dao.dart';
import '../models/category_model.dart';
import 'category_local_datasource.dart';

class CategoryLocalDatasourceImpl implements CategoryLocalDatasource {
  const CategoryLocalDatasourceImpl(this._categoriesDao);

  final CategoriesDao _categoriesDao;

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
}
