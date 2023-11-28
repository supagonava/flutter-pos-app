class Shop {
  String? code;
  String? name;
  List<Product>? products;

  Shop({this.code, this.name, this.products});
}

class Product {
  String id;
  String? name;
  double? price;
  Map<String, dynamic>? optionalData;

  Product({this.name, this.optionalData, this.price, required this.id});
  Map<String, dynamic> toMap() => ({"name": name, "price": price, 'id': id});
  Product fromMap(Map item) => Product(
        id: item['id'] ?? '',
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
