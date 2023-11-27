class Shop {
  String? code;
  String? name;

  Shop({this.code, this.name});
}

class Product {
  String? name;
  double? price;
  Map<String, dynamic>? optionalData;

  Product({this.name, this.optionalData, this.price});
  Map<String, dynamic> toMap() => ({"name": name, "price": price});
  Product fromMap(Map item) => Product(
        name: item['name'] ?? '',
        price: item['price'] ?? 0,
      );
}

class Cart {
  String? shopCode;
  int? tableNumber;
  Product? product;
  int? quantity;

  Cart({this.shopCode, this.product, this.quantity, this.tableNumber});
  Map<String, dynamic> toMap() => ({"product": product?.toMap() ?? {}, "quantity": quantity ?? 0});
}
