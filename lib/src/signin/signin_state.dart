import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class SigninState extends Equatable {
  const SigninState();

  @override
  List<Object?> get props => [];
}

class SigninInitial extends SigninState {
  const SigninInitial();
}

class SigninLoading extends SigninState {
  const SigninLoading();
}

class SigninSuccess extends SigninState {
  final User? user;

  const SigninSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class SigninFailure extends SigninState {
  final String? error;

  const SigninFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class CodeSentState extends SigninState {
  final String verificationId;
  final int? resendToken;

  const CodeSentState(this.verificationId, this.resendToken);

  @override
  List<Object?> get props => [verificationId, resendToken];
}

class CodeTimeoutState extends SigninState {
  final String verificationId;

  const CodeTimeoutState(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}
