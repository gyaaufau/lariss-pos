import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.categoryId,
    required super.name,
    required super.sellingPrice,
    required super.currentStock,
    required super.minimumStock,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory ProductModel.fromTableData(ProductsTableData data) {
    return ProductModel(
      id: data.id,
      categoryId: data.categoryId,
      name: data.name,
      sellingPrice: data.sellingPrice,
      currentStock: data.currentStock,
      minimumStock: data.minimumStock,
      isActive: data.isActive,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
    );
  }

  ProductsTableCompanion toCompanion() {
    return ProductsTableCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      sellingPrice: Value(sellingPrice),
      currentStock: Value(currentStock),
      minimumStock: Value(minimumStock),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
    );
  }

  ProductModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    int? sellingPrice,
    int? currentStock,
    int? minimumStock,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
    int? deletedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
