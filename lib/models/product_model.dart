class ProductModel {
  final String productId;
  final String name;
  final String category;
  final double price;
  final int stock;
  final int minStock;
  final bool active;

  ProductModel({
    required this.productId,
    required this.name,
    this.category = '',
    required this.price,
    required this.stock,
    this.minStock = 5,
    this.active = true,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      productId: documentId,
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      stock: map['stock']?.toInt() ?? 0,
      minStock: map['minStock']?.toInt() ?? 5,
      active: map['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'minStock': minStock,
      'active': active,
    };
  }
}
