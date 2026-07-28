class ShopModel {
  final String shopId;
  final String name;
  final String owner;
  final String phone;
  final String address;
  final String routeId;
  final double balanceDue;

  ShopModel({
    required this.shopId,
    required this.name,
    this.owner = '',
    this.phone = '',
    this.address = '',
    required this.routeId,
    this.balanceDue = 0.0,
  });

  factory ShopModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ShopModel(
      shopId: documentId,
      name: map['name']?.toString() ?? '',
      owner: map['owner']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      routeId: map['routeId']?.toString() ?? '',
      balanceDue: (map['balanceDue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'owner': owner,
      'phone': phone,
      'address': address,
      'routeId': routeId,
      'balanceDue': balanceDue,
    };
  }
}
