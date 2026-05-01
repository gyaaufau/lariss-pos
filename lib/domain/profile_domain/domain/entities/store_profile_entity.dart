class StoreProfileEntity {
  const StoreProfileEntity({
    required this.id,
    required this.storeName,
    required this.ownerName,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String storeName;
  final String ownerName;
  final int createdAt;
  final int updatedAt;
}
