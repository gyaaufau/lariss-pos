import '../../../../core/database/app_database.dart';
import '../../domain/entities/stock_product_entity.dart';

class StockProductModel extends StockProductEntity {
  const StockProductModel({
    required super.id,
    required super.categoryId,
    required super.name,
    required super.sellingPrice,
    required super.currentStock,
    required super.minimumStock,
    required super.isActive,
  });

  factory StockProductModel.fromTableData(ProductsTableData data) {
    return StockProductModel(
      id: data.id,
      categoryId: data.categoryId,
      name: data.name,
      sellingPrice: data.sellingPrice,
      currentStock: data.currentStock,
      minimumStock: data.minimumStock,
      isActive: data.isActive,
    );
  }
}
