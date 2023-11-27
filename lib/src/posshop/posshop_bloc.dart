// import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:charset_converter/charset_converter.dart';
// import 'package:image/image.dart';
// import 'package:intl/intl.dart';1
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
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
    var queryProducts = querySnapshot.data()?['products'] as List;

    for (var p in queryProducts.isNotEmpty ? queryProducts : []) {
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

    final billingNo = "${(prevState.shopCode).substring(0, 5)}-${prevState.tableNumber}-${(DateTime.now().microsecondsSinceEpoch ~/ 1000).toString().substring(0, 10)}";
    var firebaseCollection = FirebaseFirestore.instance.collection(billingRootPath).doc(billingNo);
    firebaseCollection.set(billPayload);

    final newState = prevState.copyWith(carts: []);
    em(newState);

    var branchCart = FirebaseFirestore.instance.collection(shopBrancheCartsRootPath).doc("${ev.shopCode}-cart-${ev.tableNumber}");
    branchCart.delete();

    if (ev.printer != null) {
      await printReciept(ev.printer, prevState, billingNo);
      // em(PrintingState(finishPrint: false, prevState: prevState));
    }
  }

  printReciept(PrinterBluetooth? printer, POSSellState printState, String billingNo) async {
    PrinterBluetoothManager printerManager = PrinterBluetoothManager();
    if (printer != null) {
      try {
        byteThaiChar(message) async => await CharsetConverter.encode('TIS-620', '$message');

        final shop = SHOP_BRANCH.firstWhere((el) => el.code == printState.shopCode);
        printerManager.selectPrinter(printer);
        final profile = await CapabilityProfile.load();
        final generator = Generator(PaperSize.mm58, profile);
        List<int> bytes = [];

        printBody(List<int> bytes, bool isOriginal) async {
          bytes += generator.textEncoded((await byteThaiChar('ใบเสร็จอย่างย่อ ${isOriginal ? 'ต้นฉบับ' : 'สำเนา'}')), styles: PosStyles(align: PosAlign.center));
          bytes += generator.textEncoded((await byteThaiChar(shop.name)));
          bytes += generator.text("BN: $billingNo");
          bytes += generator.text(DateTime.now().toLocal().toString());
          bytes += generator.text('', styles: PosStyles(height: PosTextSize.size2));
          double totalAmount = 0;
          for (var cart in printState.carts) {
            final recordAmount = (cart.product?.price ?? 0) * (cart.quantity ?? 0);
            bytes += generator.row([
              PosColumn(
                  text: '',
                  textEncoded: await byteThaiChar("${cart.product?.name} (${cart.product?.price} x ${cart.quantity})"),
                  width: 9,
                  styles: PosStyles(align: PosAlign.left)),
              PosColumn(text: '', textEncoded: await byteThaiChar('$recordAmount.-'), width: 3, styles: PosStyles(align: PosAlign.right)),
            ]);
            totalAmount += recordAmount;
          }
          bytes += generator.emptyLines(1);
          bytes += generator.row([
            PosColumn(text: 'Total', width: 9, styles: PosStyles(align: PosAlign.left)),
            PosColumn(text: "$totalAmount .-", width: 3, styles: PosStyles(align: PosAlign.right)),
          ]);
          return bytes;
        }

        bytes = await printBody(bytes, true);
        bytes += generator.textEncoded((await byteThaiChar('ขอบพระคุณที่มาอุดหนุนค่ะ')), styles: PosStyles(align: PosAlign.left));
        bytes += generator.textEncoded((await byteThaiChar('โอกาสหน้าเชิญชวนอีกครั้งนะคะ')), styles: PosStyles(align: PosAlign.left));
        bytes += generator.textEncoded((await byteThaiChar('ติดต่อร้าน')), styles: PosStyles(align: PosAlign.left));
        bytes += generator.textEncoded((await byteThaiChar('k\'บอย 0923457633')), styles: PosStyles(align: PosAlign.left));
        bytes += generator.textEncoded((await byteThaiChar('k\'ผึ้ง 0928707863')), styles: PosStyles(align: PosAlign.left));
        bytes += generator.emptyLines(1);
        bytes += generator.text('-------THANK YOU!---------', styles: PosStyles(align: PosAlign.center));
        bytes += generator.emptyLines(4);
        bytes = await printBody(bytes, false);
        bytes += generator.emptyLines(2);

        // Print image:
        // final ByteData data = await rootBundle.load('assets/flutter_logo.png');
        // final Uint8List imgBytes = data.buffer.asUint8List();
        // final Image image = decodeImage(imgBytes)!;
        // bytes += generator.image(image);

        // Print barcode
        // final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
        // bytes += generator.barcode(Barcode.upcA(barData));

        printerManager.printTicket(bytes);
        print("DONE!");
      } catch (e) {
        print(e);
      }
    }
  }
}
