import 'package:dimsummaster/services.dart';
import 'package:dimsummaster/src/app.dart';
import 'package:dimsummaster/src/posshop/index.dart';
import 'package:flutter/material.dart';

class ShopSettingView extends StatefulWidget {
  static const routeName = '/shop-settings';
  final Shop shop;
  const ShopSettingView({super.key, required this.shop});

  @override
  State<ShopSettingView> createState() => _ShopSettingViewState();
}

class _ShopSettingViewState extends State<ShopSettingView> {
  List<TextEditingController> contactTxtCtrs = [];
  List<TextEditingController> phoneTxtCtrs = [];
  TextEditingController shopNameTxtCtr = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      for (var i = 0; i < 3; i++) {
        contactTxtCtrs.add(TextEditingController(text: (widget.shop.contacts != null && (widget.shop.contacts ?? []).length > i) ? widget.shop.contacts![i]['contact'] : ''));
        phoneTxtCtrs.add(TextEditingController(text: (widget.shop.contacts != null && (widget.shop.contacts ?? []).length > i) ? widget.shop.contacts![i]['phone'] : ''));
      }
      shopNameTxtCtr.text = widget.shop.name ?? '-';
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageSize = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(title: Text("ตั้งค่าร้าน")),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                      TextField(
                        controller: shopNameTxtCtr,
                        decoration: InputDecoration(label: Text("ชื่อร้าน"), icon: Icon(Icons.contact_emergency_outlined)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text("เบอร์ติดต่อ (สูงสุด 3 เบอร์)"),
                      ),
                    ] +
                    (List.generate(
                      phoneTxtCtrs.length,
                      (index) => Row(
                        children: [
                          SizedBox(
                            width: pageSize.width * 0.4,
                            child: TextField(
                              controller: contactTxtCtrs[index],
                              onChanged: (val) => contactTxtCtrs[index].text = val,
                              decoration: InputDecoration(label: Text("ชื่อผู้ติดต่อ ${index + 1}"), icon: Icon(Icons.contact_emergency_outlined)),
                            ),
                          ),
                          SizedBox(
                            width: pageSize.width * 0.4,
                            child: TextField(
                              controller: phoneTxtCtrs[index],
                              keyboardType: TextInputType.phone,
                              onChanged: (val) => phoneTxtCtrs[index].text = val,
                              decoration: InputDecoration(label: Text("เบอร์ที่ ${index + 1}"), icon: Icon(Icons.phone)),
                            ),
                          ),
                        ],
                      ),
                    )) +
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: TextButton(
                            onPressed: () async {
                              widget.shop.name = shopNameTxtCtr.text;
                              final List<Map<String, String>> contacts = [];
                              for (var i = 0; i < 3; i++) {
                                if (contactTxtCtrs[i].text.trim().isNotEmpty) {
                                  contacts.add({'contact': contactTxtCtrs[i].text, 'phone': phoneTxtCtrs[i].text});
                                }
                              }
                              widget.shop.contacts = contacts;
                              await updateShopBranch(widget.shop);
                              Navigator.of(context).pop(widget.shop);
                            },
                            style: successButtonStyle,
                            child: Text("บันทึกเข้าระบบ")),
                      )
                    ]),
          ),
        ),
      ),
    );
  }
}
