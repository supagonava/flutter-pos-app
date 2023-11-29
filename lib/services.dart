import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dimsummaster/src/posshop/index.dart';

const shopBranchesRootPath = 'shopbranches';
const billingRootPath = 'billings';
const productsRootPath = 'products';
const usersRootPath = 'users';
const shopBranchCartsRootPath = 'shopbranchcarts';

getShopBranch(String shopCode) async {
  var querySnapshot = await FirebaseFirestore.instance.collection(shopBranchesRootPath).doc(shopCode).get();
  var queryData = querySnapshot.data();
  if (queryData != null) {
    List<Product> products = [];
    for (var p in queryData['products'] ?? []) {
      products.add(Product(name: p['name'], price: double.tryParse("${p['price']}"), id: p['id']));
    }
    List<Map<String, String>> contacts = [];
    for (var contact in queryData['contacts'] ?? []) {
      contacts.add({'contact': contact['contact'] ?? '', 'phone': contact['phone'] ?? ''});
    }
    return Shop(code: shopCode, name: queryData['name'] ?? 'untitled-shop', products: products, contacts: contacts);
  }
  return null;
}

updateShopBranch(Shop shop) async {
  var shopDoc = FirebaseFirestore.instance.collection(shopBranchesRootPath).doc(shop.code);
  await shopDoc.update({"contacts": shop.contacts, "name": shop.name});
}

addShopBranch({String shopcode = '', String shopname = ''}) async {
  var shopDoc = FirebaseFirestore.instance.collection(shopBranchesRootPath).doc(shopcode);
  await shopDoc.set({"products": [], "code": shopcode, 'name': shopname, 'registered_at': DateTime.now().toLocal().toString()});
}

setProductsToShop({String shopCode = '', List<Product> products = const []}) async {
  var shopDoc = FirebaseFirestore.instance.collection(shopBranchesRootPath).doc(shopCode);
  final productJson = products.map((p) => p.toMap());
  await shopDoc.update({"products": productJson});
}

getProductsInBrance(String? shopCode) async {
  List<Product> products = [];
  var querySnapshot = await FirebaseFirestore.instance.collection(shopBranchesRootPath).doc(shopCode).get();
  var queryData = querySnapshot.data();
  var data = queryData != null ? queryData['products'] as List : [];

  for (var p in data) {
    products.add(Product(name: p['name'], price: double.tryParse("${p['price']}"), id: p['id']));
  }
  return products;
}

getCartsInBranceTable(String shopCode, int tableNo) async {
  List<Cart> carts = [];
  var querySnapshot = await FirebaseFirestore.instance.collection(shopBranchCartsRootPath).doc("$shopCode-cart-$tableNo").get();
  var queryData = querySnapshot.data();
  var data = queryData != null ? queryData['products'] as List : [];
  for (var p in data) {
    carts.add(Cart(quantity: p['quantity'], product: Product(name: p['product']['name'], price: p['product']['price'], id: p['product']['id'])));
  }
  return carts;
}

getUsersInBrance({String shopCode = ""}) async {}
