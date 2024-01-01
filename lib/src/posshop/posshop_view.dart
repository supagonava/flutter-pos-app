import 'package:dimsummaster/services.dart';
import 'package:dimsummaster/src/app.dart';
import 'package:dimsummaster/src/constants.dart';
import 'package:dimsummaster/src/posshop/index.dart';
import 'package:dimsummaster/src/shopsetting/shopsetting_view.dart';
import 'package:dimsummaster/src/signin/signin_view.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

class PosShopView extends StatelessWidget {
  static const routeName = "/home";
  const PosShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return POSScreenView();
  }
}

class POSScreenView extends StatelessWidget {
  const POSScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PosshopBloc, PosshopState>(
        listener: (context, state) {},
        child: GestureDetector(
          onTap: () => unfocus(context),
          child: BlocBuilder<PosshopBloc, PosshopState>(builder: (context, state) {
            String title = 'หน้าขายหลัก';
            Widget pageBody = Center(child: Text("State ${state.toString()}..."));
            List<Widget> appBarActions = [];

            if (state is InitialState) {
              title = 'เข้าสู่ระบบ';
              appBarActions = [IconButton(onPressed: () => SystemNavigator.pop(), icon: Icon(Icons.exit_to_app_outlined, color: Colors.redAccent))];
              Widget shopHeaderWidgets = SigninView();
              pageBody = SingleChildScrollView(child: Column(children: [shopHeaderWidgets]));
            } else if (state is POSSellState) {
              title = "${state.shop.name} (${state.shop.code})";
              appBarActions = [
                IconButton(
                    onPressed: () async {
                      Shop? shopSetting = await Navigator.of(context).push(MaterialPageRoute(builder: (builder) => ShopSettingView(shop: state.shop)));
                      if (shopSetting != null) {
                        BlocProvider.of<PosshopBloc>(context).add(OpenPosPageEvent(shopCode: state.shopCode, tableNo: state.tableNumber));
                      }
                    },
                    icon: Icon(Icons.settings)),
                IconButton(onPressed: () => BlocProvider.of<PosshopBloc>(context).add(OpenSettingPageEvent(state.shopCode)), icon: Icon(Icons.list_alt)),
                IconButton(onPressed: () => BlocProvider.of<PosshopBloc>(context).add(OpenPosPageEvent(shopCode: null)), icon: Icon(Icons.arrow_back_ios)),
              ];
              pageBody = posSellView(context, state);
            } else if (state is SettingPageState) {
              title = 'ตั้งค่าสินค้า';
              appBarActions = [
                IconButton(onPressed: () => BlocProvider.of<PosshopBloc>(context).add(OpenPosPageEvent(shopCode: state.shopCode)), icon: Icon(Icons.arrow_back_ios)),
              ];
              pageBody = SettingProductView();
            }
            return Scaffold(
              appBar: AppBar(title: Text(title), actions: appBarActions),
              body: pageBody,
              resizeToAvoidBottomInset: true,
            );
          }),
        ));
  }
}

class PickPrinterDeviceView extends StatefulWidget {
  final POSSellState state;
  const PickPrinterDeviceView(this.state, {super.key});

  @override
  State<PickPrinterDeviceView> createState() => _PickPrinterDeviceViewState();
}

class _PickPrinterDeviceViewState extends State<PickPrinterDeviceView> {
  List<PrinterBluetooth> devices = [];
  bool scanning = false;
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  String billingNo = "";

  Future<void> scanDevices() async {
    printerManager.scanResults.listen((scanResults) {
      print('${DateTime.now()} scanResults $scanResults');
      setState(() => devices = scanResults);
    });
    printerManager.isScanningStream.listen((evScaning) => setState(() => scanning = evScaning));
    printerManager.startScan(Duration(seconds: 15));
  }

  @override
  void initState() {
    super.initState();
    scanDevices();
    billingNo = "${(widget.state.shopCode).substring(0, 5)}-${widget.state.tableNumber}-${(DateTime.now().microsecondsSinceEpoch ~/ 1000).toString().substring(0, 10)}";
  }

  @override
  void dispose() {
    super.dispose();
    printerManager.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> printerListTileWidgets = List.generate(
        devices.length,
        (index) => ListTile(
              leading: Icon(Icons.print_outlined),
              title: Text(devices[index].name.toString()),
              subtitle: Text('แตะเพื่อพิมพ์'),
              onTap: () async {
                printerManager.stopScan();

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Message'),
                    content: Text('หากใน 10 วินาที เครื่องไม่พิมพ์ ให้กดรีโหลดมุมขวาบนแล้วเลือกเครื่องพิมพ์เพื่อพิมพ์อีกครั้ง'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
                Fluttertoast.showToast(msg: "กำลังพิมพ์ใบเสร็จ");
                await printReciept(devices[index], widget.state, billingNo, widget.state.shop.name ?? widget.state.shopCode);
                // Show the message dialog
              },
            ));
    printerListTileWidgets.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
              onPressed: () {
                // without print
                BlocProvider.of<PosshopBloc>(context)
                    .add(SubmitPurchaseOrderEvent(shopCode: widget.state.shopCode, tableNumber: widget.state.tableNumber, carts: widget.state.carts, billingNo: billingNo));
                Navigator.of(context).pop();
              },
              style: successButtonStyle,
              child: Text("พิมพ์สำเร็จแล้ว"))
        ],
      ),
    ));
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("เลือกเครื่องปริ้นท์"),
          actions: scanning
              ? [Padding(padding: const EdgeInsets.all(8.0), child: CircularProgressIndicator())]
              : [IconButton(onPressed: () => scanDevices(), icon: Icon(Icons.refresh_outlined))],
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                printerManager.stopScan();
                Navigator.of(context).pop(null);
              }),
        ),
        body: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.76,
            child: SingleChildScrollView(
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: printerListTileWidgets),
            )));
  }
}

Widget posSellView(BuildContext context, POSSellState state) {
  final Size pageSize = getPageSize(context);

  int totalQTY = 0;
  double totalAmount = 0;
  List<Widget> productListPOSWidget = [];

  void handleClearCarts() {
    BlocProvider.of<PosshopBloc>(context).add(UpdateTableCartsEvent(carts: [], shopCode: state.shopCode, tableNumber: state.tableNumber));
  }

  void handleSubmitPurchase() async {
    print("submit purchased");
    if (state.carts.isEmpty) {
      Fluttertoast.showToast(
          msg: "สินค้าในตะกร้าว่างเปล่า",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(builder: (builder) => PickPrinterDeviceView(state)));
    // if (selectedPrinter != null) {
    //   BlocProvider.of<PosshopBloc>(context)
    //       .add(SubmitPurchaseOrderEvent(shopCode: state.shopCode, tableNumber: state.tableNumber, carts: state.carts, printer: selectedPrinter != false ? selectedPrinter : null));
    // } else {
    //   Fluttertoast.showToast(
    //       msg: "ไม่ได้เลือก Printer",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.CENTER,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    // }
  }

  void handleAddProductQTY({required Product product, int qty = 1}) {
    List<Cart> updatedCarts = [...state.carts];

    final existCartIndex = updatedCarts.indexWhere((c) => c.product?.id == product.id && c.shopCode == state.shopCode && c.tableNumber == state.tableNumber);
    if (existCartIndex >= 0) {
      Cart existingCart = updatedCarts[existCartIndex];
      updatedCarts[existCartIndex] = Cart(
        product: existingCart.product,
        quantity: (existingCart.quantity ?? 0) + qty,
        shopCode: existingCart.shopCode,
        tableNumber: existingCart.tableNumber,
      );
    } else {
      updatedCarts.add(Cart(product: product, quantity: qty, shopCode: state.shopCode, tableNumber: state.tableNumber));
    }

    BlocProvider.of<PosshopBloc>(context).add(UpdateTableCartsEvent(carts: updatedCarts, shopCode: state.shopCode, tableNumber: state.tableNumber));
  }

  void handleRemoveProductQTY({required Product product, int qty = 1}) {
    List<Cart> updatedCarts = [...state.carts];

    final existCartIndex = updatedCarts.indexWhere((c) => c.product?.id == product.id);
    if (existCartIndex >= 0) {
      Cart existingCart = updatedCarts[existCartIndex];
      int newQuantity = (existingCart.quantity ?? 0) - qty;
      if (newQuantity > 0) {
        updatedCarts[existCartIndex] = Cart(
          product: existingCart.product,
          quantity: newQuantity,
          shopCode: existingCart.shopCode,
          tableNumber: existingCart.tableNumber,
        );
      } else {
        updatedCarts.removeAt(existCartIndex);
      }
    }

    BlocProvider.of<PosshopBloc>(context).add(UpdateTableCartsEvent(carts: updatedCarts, shopCode: state.shopCode, tableNumber: state.tableNumber));
  }

  for (var product in (state.products)) {
    int cartItemIndex = state.carts.indexWhere((ct) => ct.product?.name == product.name);
    Cart? cartItem = cartItemIndex >= 0 ? state.carts[cartItemIndex] : null;
    productListPOSWidget.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ListTile(
        title: Text("${product.name}"),
        subtitle: Text("จำนวนชิ้น ${cartItem?.quantity ?? 0} รวม ${(cartItem?.quantity ?? 0) * (cartItem?.product?.price ?? 0)} บาท"),
        trailing: SizedBox(
          height: 50,
          width: 100,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(onPressed: () => handleAddProductQTY(product: product), icon: Icon(Icons.plus_one), style: successButtonStyle),
              IconButton(onPressed: () => handleRemoveProductQTY(product: product), icon: Icon(Icons.exposure_minus_1), style: deleteButtonStyle),
            ],
          ),
        ),
      ),
    ));
  }

  if (state.carts.isNotEmpty) {
    totalQTY = state.carts.map((c) => (c.quantity ?? 0)).reduce((qty, prevQty) => qty + prevQty);
    totalAmount = double.tryParse(state.carts.map((c) => (c.quantity ?? 0) * (c.product?.price ?? 0)).reduce((qty, prevQty) => qty + prevQty).toString()) ?? 0;
  }

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () async {
                Fluttertoast.showToast(msg: "กำลังเปิดหน้า History");
                var url = "https://docs.google.com/spreadsheets/";
                var sheetURL = await getHistorySheetURL(state.shopCode);
                if (!sheetURL['status']) {
                  Fluttertoast.showToast(msg: "ล้มเหลวในการเปิด");
                } else {
                  url = sheetURL['url'];
                  Fluttertoast.showToast(msg: "กำลังเปิด $url");
                  await launchUrl(Uri.parse(url));
                }
              },
              child: Text("ดูประวัติขาย"),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Flex(direction: Axis.horizontal, children: [Text("ที่กำลังบริการ :")]),
        ),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: List.generate(
                    TABLE_NAMES.entries.length,
                    (index) => ElevatedButton(
                          style: index == state.tableNumber ? successButtonStyle : null,
                          onPressed: () => BlocProvider.of<PosshopBloc>(context).add(OpenPosPageEvent(shopCode: state.shopCode, tableNo: index)),
                          child: Text(TABLE_NAMES[index]!),
                        )))),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Flex(direction: Axis.horizontal, children: [Text("รวมชิ้น : $totalQTY ชิ้น")]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Flex(direction: Axis.horizontal, children: [Text("รวมบาท : $totalAmount THB")]),
        ),
        Divider(),
        SizedBox(
          height: pageSize.height * 0.43,
          width: pageSize.width,
          child: SingleChildScrollView(child: Column(children: productListPOSWidget)),
        ),
        Divider(),
        Flex(direction: Axis.horizontal, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ElevatedButton(
            onPressed: () => handleSubmitPurchase(),
            style: successButtonStyle,
            child: SizedBox(width: pageSize.width * 0.3, child: Text("ชำระเงิน")),
          ),
          ElevatedButton(
            onPressed: () => handleClearCarts(),
            style: deleteButtonStyle,
            child: SizedBox(width: pageSize.width * 0.3, child: Text("ยกเลิก")),
          )
        ]),
      ],
    ),
  );
}

class SettingProductView extends StatelessWidget {
  const SettingProductView({super.key});

  @override
  Widget build(BuildContext context) {
    var state = BlocProvider.of<PosshopBloc>(context).state as SettingPageState;
    var pageSize = MediaQuery.of(context).size;

    String shopCode = state.shopCode ?? '';
    List<Product> productItems = [...(state.products ?? [])];
    List<Map<String, TextEditingController>> textControllers = [];
    for (var product in productItems) {
      Map<String, TextEditingController> item = {
        "nameController": TextEditingController(text: product.name),
        "priceController": TextEditingController(text: product.price.toString()),
      };
      textControllers.add(item);
    }

    handleSubmitChangeProducts({isSubmit = false}) {
      BlocProvider.of<PosshopBloc>(context).add(UpdateProductsInShopEvent(shopCode: shopCode, isSubmit: isSubmit, products: productItems));
    }

    handelClickAddProduct() {
      var nameTextEditer = TextEditingController(text: "สินค้าใหม่ ${productItems.length + 1}");
      var priceTextEditer = TextEditingController(text: "0.00");
      Product product = Product(name: nameTextEditer.text, price: double.tryParse(priceTextEditer.text), id: Uuid().v4());
      productItems.add(product);
      handleSubmitChangeProducts();
    }

    handleDeleteProduct(int index) {
      productItems.removeAt(index);
      textControllers.removeAt(index);
      handleSubmitChangeProducts();
    }

    return SizedBox(
      height: pageSize.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Flex(
              direction: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(onPressed: () => handelClickAddProduct(), child: Text("เพิ่มสินค้า +")),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(onPressed: () => handleSubmitChangeProducts(isSubmit: true), style: successButtonStyle, child: Text("บันทึกเข้าระบบ")),
                )
              ],
            ),
            Column(
              children: List.generate(productItems.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    // leading: CircleAvatar(child: Text("${index + 1}")),
                    title: TextField(
                        onChanged: (val) => productItems[index].name = val,
                        controller: textControllers[index]['nameController'],
                        decoration: InputDecoration(
                          hintText: 'คลิกเพื่อแก้ไขชื่อสินค้า',
                          icon: Icon(Icons.discount_outlined),
                        )),
                    subtitle: Flex(
                      direction: Axis.horizontal,
                      children: [
                        SizedBox(
                          height: 80,
                          width: 150,
                          child: TextField(
                              onChanged: (val) => productItems[index].price = double.tryParse(val),
                              controller: textControllers[index]['priceController'],
                              decoration: InputDecoration(
                                hintText: 'คลิกเพื่อแก้ไขราคา',
                                icon: Icon(Icons.monetization_on_outlined),
                              )),
                        )
                      ],
                    ),
                    trailing: IconButton(
                      style: deleteButtonStyle,
                      icon: Icon(Icons.delete_forever_outlined),
                      onPressed: () => handleDeleteProduct(index),
                    ),
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}
