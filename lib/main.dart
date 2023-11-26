import 'package:dimsummaster/src/posshop/index.dart';
import 'package:dimsummaster/src/signin/signin_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (context) => SigninBloc()),
    BlocProvider(create: (context) => PosshopBloc()),
  ], child: MyApp()));
}
