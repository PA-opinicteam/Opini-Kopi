class StockItem {
  final String id;
  final String productName;
  final String category;
  final num stock;
  final String unit;

  const StockItem({
    required this.id,
    required this.productName,
    required this.category,
    required this.stock,
    required this.unit,
  });

  factory StockItem.fromMap(Map<String, dynamic> map) {
    return StockItem(
      id: (map['id_inventory'] ?? '').toString(),
      productName: (map['product_name'] ?? '').toString(),
      category: (map['category'] ?? 'Bahan Baku').toString(),
      stock: (map['stock'] ?? 0) as num,
      unit: (map['unit'] ?? '').toString(),
    );
  }
}
