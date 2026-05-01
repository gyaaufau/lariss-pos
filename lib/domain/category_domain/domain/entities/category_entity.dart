class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
}
