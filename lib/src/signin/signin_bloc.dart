import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'index.dart';

class SigninBloc extends Bloc<SigninEvent, SigninState> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  SigninBloc() : super(SigninInitial()) {
    on<VerifyPhoneNumber>(verifyPhoneNumber);
  }

  Future<void> verifyPhoneNumber(VerifyPhoneNumber event, Emitter<SigninState> emit) async {
    String phoneNumber = event.phoneNumber ?? '';
    if (phoneNumber.startsWith("0")) {
      phoneNumber = "+66${phoneNumber.substring(1)}";
    }

    Completer<void> completer = Completer<void>();
    try {
      emit(SigninLoading());

      auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            UserCredential userCredential = await auth.signInWithCredential(credential);
            emit(SigninSuccess(userCredential.user));
            completer.complete();
          } catch (e) {
            emit(SigninFailure(e.toString()));
            completer.completeError(e);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(SigninFailure(e.message));
          completer.completeError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          emit(CodeSentState(verificationId, resendToken));
          completer.complete();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          emit(CodeTimeoutState(verificationId));
          completer.complete();
        },
      );

      return completer.future;
    } catch (e) {
      emit(SigninFailure(e.toString()));
      completer.completeError(e);
    }
  }
}
