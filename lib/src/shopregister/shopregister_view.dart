import 'package:dimsummaster/helper.dart';
import 'package:dimsummaster/services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class ShopRegisterView extends StatefulWidget {
  static const routeName = "/shop-register";
  const ShopRegisterView({super.key});

  @override
  State<ShopRegisterView> createState() => _ShopRegisterViewState();
}

class _ShopRegisterViewState extends State<ShopRegisterView> {
  final TextEditingController codeTxtCtr = TextEditingController(text: Uuid().v4().substring(0, 5));
  final TextEditingController shopnameTxtCtr = TextEditingController();

  @override
  void initState() {
    setState(() => shopnameTxtCtr.text = "ร้านไม่มีชื่อ");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    onSubmitRegister() async {
      if (codeTxtCtr.text.trim().isEmpty || shopnameTxtCtr.text.trim().isEmpty) {
        Fluttertoast.showToast(msg: 'โปรดข้อมูลให้ครบถ้วน');
        return;
      }
      if (codeTxtCtr.text.length != 5) {
        Fluttertoast.showToast(msg: 'โค้ดร้านต้องมี 5 หลัก');
        return;
      }
      final shopProfile = await getShopBranch(codeTxtCtr.text);
      if (shopProfile == null) {
        // print("OK!");
        addShopBranch(shopcode: codeTxtCtr.text, shopname: shopnameTxtCtr.text);

        await showDialog(
            context: context,
            builder: (builder) => AlertDialog(
                  title: Text('โปรดจำโค้ดนี้ ${codeTxtCtr.text} เพื่อใช้เข้าระบบครั้งต่อไป'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ));
        Navigator.of(context).pop();
      } else {
        Fluttertoast.showToast(msg: 'โค้ดร้านซ้ำ');
      }
    }

    return GestureDetector(
      onTap: () => unfocus(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ลงทะเบียนร้านใหม่'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // TextField(controller: codeTxtCtr, decoration: InputDecoration(label: Text("โค้ดร้าน")), maxLength: 5),
                TextField(controller: shopnameTxtCtr, decoration: InputDecoration(label: Text("ชือร้าน"))),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ElevatedButton(onPressed: () async => await onSubmitRegister(), child: Text("ลงทะเบียน")),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
