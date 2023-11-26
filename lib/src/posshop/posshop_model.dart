import 'dart:ffi';

class Shop {
  final String? code;
  final String? name;

  const Shop({this.code, this.name});
}

class Product {
  final String? name;
  final Float? price;
  final Map<String, dynamic>? optionalData;

  const Product({this.name, this.price, this.optionalData});
}

class Cart {
  final String? shopCode;
  final Product? product;
  final Int? quantity;

  const Cart({this.shopCode, this.product, this.quantity});
}
