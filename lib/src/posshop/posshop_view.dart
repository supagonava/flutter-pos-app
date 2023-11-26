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
            title = 'กรุเลือกสาขาร้านก่อน';
            Widget shopHeaderWidgets = Padding(
                padding: const EdgeInsets.all(4),
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: List.generate(
                            SHOP_BRANCH.length,
                            (index) => SizedBox(
                                width: 150,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                                  child: ElevatedButton(
                                      onPressed: () => 0,
                                      child: Text(
                                        "${SHOP_BRANCH[index].name}",
                                        overflow: TextOverflow.fade,
                                        style: defaultButtonTextStyle,
                                      )),
                                ))))));
            pageBody = SingleChildScrollView(child: Column(children: [shopHeaderWidgets]));
          } else if (state is POSSellState) {
            appBarActions = [
              IconButton(onPressed: () => signOutUser(), icon: Icon(Icons.settings, color: Colors.black54)),
              IconButton(onPressed: () => signOutUser(), icon: Icon(Icons.exit_to_app_outlined, color: Colors.amber.shade500)),
            ];
          }

          return Scaffold(appBar: AppBar(title: Text(title), actions: appBarActions), body: pageBody);
        }));
  }
}
