import 'package:dimsummaster/src/app.dart';
import 'package:dimsummaster/src/posshop/index.dart';
import 'package:dimsummaster/src/signin/signin_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter_bloc/flutter_bloc.dart";

class PosShopView extends StatelessWidget {
  static const routeName = "/home";
  const PosShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // Check if the user is logged in
            if (snapshot.data == null) {
              // User is not logged in, redirect to login
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacementNamed(SignInView.routeName);
              });
            }
            // User is logged in, show the main screen
            return POSScreenView();
          }

          // Waiting for authentication state to be available
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        });
  }
}

class POSScreenView extends StatelessWidget {
  const POSScreenView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // var pageSize = MediaQuery.sizeOf(context);

    void signOutUser() async {
      try {
        await FirebaseAuth.instance.signOut();
        print("User signed out successfully");
        WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.of(context).pushNamedAndRemoveUntil(SignInView.routeName, (route) => false));
      } catch (e) {
        print("Error signing out: $e");
      }
    }

    return BlocListener<PosshopBloc, PosshopState>(
        listener: (context, state) {},
        child: BlocBuilder<PosshopBloc, PosshopState>(builder: (context, state) {
          String title = 'หน้าขายหลัก';
          Widget pageBody = Center(child: Text("State ${state.toString()}..."));
          List<Widget> appBarActions = [];

          if (state is InitialState) {
            title = 'กรุเลือกสาขาร้าน';
            appBarActions = [IconButton(onPressed: () => signOutUser(), icon: Icon(Icons.exit_to_app_outlined, color: Colors.redAccent))];
            Widget shopHeaderWidgets = BranchSelectView();
            pageBody = SingleChildScrollView(child: Column(children: [shopHeaderWidgets]));
          } else if (state is POSSellState) {
            title = '${SHOP_BRANCH.firstWhere((b) => b.code == state.shopCode).name}';
            appBarActions = [
              IconButton(onPressed: () => BlocProvider.of<PosshopBloc>(context).add(OpenSettingPageEvent(state.shopCode)), icon: Icon(Icons.settings)),
              IconButton(onPressed: () => BlocProvider.of<PosshopBloc>(context).add(OpenPosPageEvent(null)), icon: Icon(Icons.arrow_back_ios)),
            ];
          } else if (state is SettingPageState) {
            title = 'ตั้งค่าสินค้า';
            appBarActions = [
              IconButton(onPressed: () => BlocProvider.of<PosshopBloc>(context).add(OpenPosPageEvent(state.shopCode)), icon: Icon(Icons.arrow_back_ios)),
            ];
            pageBody = SettingProductView();
          }

          return Scaffold(appBar: AppBar(title: Text(title), actions: appBarActions), body: pageBody);
        }));
  }
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

    submitChangeProducts({isSubmit = false}) {
      BlocProvider.of<PosshopBloc>(context).add(UpdateProductsInShopEvent(shopCode: shopCode, isSubmit: isSubmit, products: productItems));
    }

    handelClickAddProduct() {
      var nameTextEditer = TextEditingController(text: "สินค้าใหม่ ${productItems.length + 1}");
      var priceTextEditer = TextEditingController(text: "0.00");
      Product product = Product(name: nameTextEditer.text, price: double.tryParse(priceTextEditer.text), optionalData: {'disabled': true});
      productItems.add(product);
      submitChangeProducts();
    }

    handleDeleteProduct(int index) {
      productItems.removeAt(index);
      textControllers.removeAt(index);
      submitChangeProducts();
    }

    return Flex(
      direction: Axis.vertical,
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
              child: TextButton(onPressed: () => submitChangeProducts(isSubmit: true), style: successButtonStyle, child: Text("บันทึกเข้าระบบ")),
            )
          ],
        ),
        SizedBox(
            height: pageSize.height * 0.75,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
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
              ),
            ))
      ],
    );
  }
}

class BranchSelectView extends StatelessWidget {
  const BranchSelectView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(4),
        child: Wrap(
            children: List.generate(
                SHOP_BRANCH.length,
                (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                      child: ElevatedButton(
                          onPressed: () => BlocProvider.of<PosshopBloc>(context).add(OpenPosPageEvent(SHOP_BRANCH[index].code)),
                          child: Text(
                            "${SHOP_BRANCH[index].name}",
                            overflow: TextOverflow.fade,
                            style: defaultButtonTextStyle,
                          )),
                    ))));
  }
}
