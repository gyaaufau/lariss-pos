import '../models/category_model.dart';

abstract class CategoryLocalDatasource {
  Future<List<CategoryModel>> getCategories();

  Future<CategoryModel?> getCategoryById(String id);

  Future<CategoryModel> createCategory(String name);

  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
    required int createdAt,
  });

  Future<void> deleteCategory(String id);

  Future<int> getActiveProductCount(String categoryId);
}
