import '../models/category_model.dart';

abstract class CategoryLocalDatasource {
  Future<List<CategoryModel>> getCategories();

  Future<CategoryModel> createCategory(String name);
}
