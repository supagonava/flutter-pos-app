import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'index.dart';

class PosshopBloc extends Bloc<PosshopEvent, PosshopState> {
  final shopBranchesRootPath = 'shopbranches';
  final billingRootPath = 'billings';
  final productsRootPath = 'products';
  final usersRootPath = 'users';
  final shopBrancheCartsRootPath = 'shopbranchcarts';

  getProductsInBrance(String? shopCode) async {
    List<Product> products = [];
    var querySnapshot = await FirebaseFirestore.instance.collection(shopBranchesRootPath).doc(shopCode).get();
    var queryProducts = querySnapshot.data();
    var data = queryProducts != null ? queryProducts['products'] as List : [];

    for (var p in data) {
      products.add(Product(name: p['name'], price: p['price']));
    }
    return products;
  }

  getCartsInBranceTable(String shopCode, int tableNo) async {
    List<Cart> carts = [];
    var querySnapshot = await FirebaseFirestore.instance.collection(shopBrancheCartsRootPath).doc("$shopCode-cart-$tableNo").get();
    var queryProducts = querySnapshot.data();
    var data = queryProducts != null ? queryProducts['products'] as List : [];
    for (var p in data) {
      carts.add(Cart(quantity: p['quantity'], product: Product(name: p['product']['name'], price: p['product']['price'])));
    }
    return carts;
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
    on<UpdateTableCartsEvent>((ev, em) => updateTableCarts(ev, em));
    on<SubmitPurchaseOrderEvent>((ev, em) => submitPurchaseOrder(ev, em));
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
      var carts = await getCartsInBranceTable(event.shopCode ?? '', event.tableNo ?? 0);
      emit(POSSellState(products: products, shopCode: event.shopCode ?? '', tableNumber: event.tableNo ?? 0, carts: carts));
    }
  }

  updateProductsInShop(UpdateProductsInShopEvent event, Emitter<PosshopState> emit) async {
    final listProds = event.products as List<Product>;
    emit(SettingPageState(products: listProds, users: [], shopCode: event.shopCode));
    if (event.isSubmit) {
      print("submit to firestore!");
      await saveProductsToBranch(products: listProds, shopCode: event.shopCode);
      var carts = await getCartsInBranceTable(event.shopCode, 0);
      emit(POSSellState(shopCode: event.shopCode, tableNumber: 0, products: listProds, carts: carts));
    }
  }

  updateTableCarts(UpdateTableCartsEvent ev, Emitter<PosshopState> em) {
    final submitState = (state as POSSellState).copyWith(carts: ev.carts);
    em(submitState);
    // update to firebase
    var branchCart = FirebaseFirestore.instance.collection(shopBrancheCartsRootPath).doc("${ev.shopCode}-cart-${ev.tableNumber}");
    branchCart.set({"products": ev.carts.map((p) => p.toMap())});
  }

  submitPurchaseOrder(SubmitPurchaseOrderEvent ev, Emitter<PosshopState> em) async {
    final prevState = (state as POSSellState).copyWith();
    final Map<String, dynamic> billPayload = {
      "datetime": DateTime.now().toLocal().toString(),
      "carts": prevState.carts.map((c) => c.toMap()),
      "shopCode": prevState.shopCode,
      "tableNumber": prevState.tableNumber,
    };

    var firebaseCollection = FirebaseFirestore.instance.collection(billingRootPath).doc(ev.billingNo);
    firebaseCollection.set(billPayload);

    final newState = prevState.copyWith(carts: []);
    em(newState);

    var branchCart = FirebaseFirestore.instance.collection(shopBrancheCartsRootPath).doc("${ev.shopCode}-cart-${ev.tableNumber}");
    branchCart.set({"products": []});
  }
}
