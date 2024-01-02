import 'package:dimsummaster/services.dart';
import 'package:dimsummaster/src/posshop/index.dart';
import 'package:dimsummaster/src/shopregister/shopregister_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SigninView extends StatelessWidget {
  const SigninView({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController codeInputTxtController = TextEditingController(text: "a9da1");
    handleSignin() async {
      final Shop? shopProfile = await getShopBranch(codeInputTxtController.text);
      if (shopProfile != null) {
        BlocProvider.of<PosshopBloc>(context).add(OpenPosPageEvent(shopCode: shopProfile.code));
      } else {
        Fluttertoast.showToast(msg: "ไม่พบร้านดังกล่าว");
      }
    }

    return Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(controller: codeInputTxtController, decoration: InputDecoration(hintText: "กรอกโค้ดร้าน"), maxLength: 5),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: (() async => handleSignin()), child: Text("เข้าสู่ระบบ")),
                ElevatedButton(onPressed: (() => Navigator.of(context).pushNamed(ShopRegisterView.routeName)), child: Text("ลงทะเบียนร้าน"))
              ],
            )
            // Wrap(
            //     children: List.generate(
            //         SHOP_BRANCH.length,
            //         (index) => Padding(
            //               padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
            //               child: ElevatedButton(
            //                   onPressed: () => BlocProvider.of<PosshopBloc>(context).add(OpenPosPageEvent(shopCode: SHOP_BRANCH[index].code)),
            //                   child: Text(
            //                     "${SHOP_BRANCH[index].name}",
            //                     overflow: TextOverflow.fade,
            //                     style: defaultButtonTextStyle,
            //                   )),
            //             ))),
          ],
        ));
  }
}
