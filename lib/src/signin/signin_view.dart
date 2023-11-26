import 'package:dimsummaster/src/posshop/posshop_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';

class SignInView extends StatelessWidget {
  static const routeName = "/signin";
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final phoneTextInputController = TextEditingController();
    final otpTextInputController = TextEditingController();

    return BlocListener<SigninBloc, SigninState>(
      listener: (context, state) {
        if (state is SigninSuccess) {
          Navigator.of(context).pushReplacementNamed('/');
        } else if (state is SigninSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(PosShopView.routeName, (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login Page"),
          centerTitle: true,
        ),
        body: SizedBox(
          height: screenSize.height - 56,
          width: screenSize.width,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<SigninBloc, SigninState>(
                builder: (context, state) {
                  if (state is CodeSentState) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: otpTextInputController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(border: OutlineInputBorder(), labelText: "กรอก OTP"),
                        ),
                        ElevatedButton(
                          onPressed: () => {BlocProvider.of<SigninBloc>(context).add(SignInWithOTP(otpTextInputController.text, state.verificationId))},
                          child: const Text("ยืนยัน OTP"),
                        )
                      ],
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: phoneTextInputController,
                          decoration: InputDecoration(border: OutlineInputBorder(), labelText: "กรอกเบอร์ 10 หลัก"),
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                        ),
                        ElevatedButton(
                          onPressed: () => BlocProvider.of<SigninBloc>(context).add(VerifyPhoneNumber(phoneTextInputController.text)),
                          child: const Text("ขอ OTP เข้าระบบ"),
                        )
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
