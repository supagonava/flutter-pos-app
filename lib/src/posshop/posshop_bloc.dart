import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dimsummaster/services.dart';
import 'index.dart';

class PosshopBloc extends Bloc<PosshopEvent, PosshopState> {
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
      // var products = await getProductsInBrance(event.shopCode);
      var carts = await getCartsInBranceTable(event.shopCode ?? '', event.tableNo ?? 0);
      Shop shop = await getShopBranch(event.shopCode ?? '');
      emit(POSSellState(products: shop.products ?? [], shopCode: event.shopCode ?? '', tableNumber: event.tableNo ?? 0, carts: carts, shop: shop));
    }
  }

  updateProductsInShop(UpdateProductsInShopEvent event, Emitter<PosshopState> emit) async {
    final listProds = event.products as List<Product>;
    emit(SettingPageState(products: listProds, users: [], shopCode: event.shopCode));
    if (event.isSubmit) {
      print("submit to firestore!");
      await setProductsToShop(products: listProds, shopCode: event.shopCode);
      var carts = await getCartsInBranceTable(event.shopCode, 0);
      Shop shop = await getShopBranch(event.shopCode);
      emit(POSSellState(shopCode: event.shopCode, tableNumber: 0, products: listProds, carts: carts, shop: shop));
    }
  }

  updateTableCarts(UpdateTableCartsEvent ev, Emitter<PosshopState> em) {
    final submitState = (state as POSSellState).copyWith(carts: ev.carts);
    em(submitState);
    // update to firebase
    var branchCart = FirebaseFirestore.instance.collection(shopBranchCartsRootPath).doc("${ev.shopCode}-cart-${ev.tableNumber}");
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

    var branchCart = FirebaseFirestore.instance.collection(shopBranchCartsRootPath).doc("${ev.shopCode}-cart-${ev.tableNumber}");
    branchCart.set({"products": []});
  }
}
