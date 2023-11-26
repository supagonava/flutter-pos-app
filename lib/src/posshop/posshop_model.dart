import 'dart:ffi';

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
}

class Cart {
  String? shopCode;
  Product? product;
  Int? quantity;

  Cart({this.shopCode, this.product, this.quantity});
}
