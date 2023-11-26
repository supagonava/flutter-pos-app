import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'index.dart';

class PosshopBloc extends Bloc<PosshopEvent, PosshopState> {
  final shopBranchesRootPath = 'shopbranches';
  final productsRootPath = 'products';
  final usersRootPath = 'users';

  getProductsInBrance(String? shopCode) async {
    List<Product> products = [];
    var querySnapshot = await FirebaseFirestore.instance.collection(shopBranchesRootPath).doc(shopCode).get();
    var queryProducts = querySnapshot.data()?['products'] as List;

    for (var p in queryProducts.isNotEmpty ? queryProducts : []) {
      products.add(Product(name: p['name'], price: p['price']));
    }
    return products;
  }

  saveProductsToBranch({String shopCode = '', List<Product> products = const []}) async {
    var shopDoc = FirebaseFirestore.instance.collection(shopBranchesRootPath).doc(shopCode);
    await shopDoc.set({"products": products.map((p) => p.toMap())});
  }

  getUsersInBrance({String shopCode = ""}) async {}

  PosshopBloc() : super(InitialState()) {
    on<PosshopEvent>((event, emit) {});
    on<OpenPosPageEvent>((event, emit) => openPosPage(event, emit));
    on<OpenSettingPageEvent>((event, emit) => openSettingPage(event, emit));
    on<UpdateProductsInShopEvent>((event, emit) => updateProductsInShop(event, emit));
  }

  openSettingPage(OpenSettingPageEvent event, Emitter<PosshopState> emit) async {
    var products = await getProductsInBrance(event.shopCode);
    emit(SettingPageState(products: products, users: [], shopCode: event.shopCode));
  }

  openPosPage(OpenPosPageEvent event, Emitter<PosshopState> emit) async {
    if (event.shopCode == null) {
      emit(InitialState());
    } else {
      var products = await getProductsInBrance(event.shopCode);
      emit(POSSellState(products: products, shopCode: event.shopCode, tableNumber: 0));
    }
  }

  updateProductsInShop(UpdateProductsInShopEvent event, Emitter<PosshopState> emit) async {
    emit(SettingPageState(products: event.products, users: [], shopCode: event.shopCode));
    if (event.isSubmit) {
      print("submit to firestore!");
      await saveProductsToBranch(products: event.products as List<Product>, shopCode: event.shopCode);
      emit(POSSellState(shopCode: event.shopCode, tableNumber: 0, products: event.products));
    }
  }
}
