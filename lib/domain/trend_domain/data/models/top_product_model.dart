import '../../domain/entities/top_product_entity.dart';

class TopProductModel extends TopProductEntity {
  const TopProductModel({
    required super.productName,
    required super.totalQuantity,
    required super.totalSales,
  });
}
