import 'package:equatable/equatable.dart';

abstract class SigninEvent extends Equatable {
  const SigninEvent();

  @override
  List<Object?> get props => [];
}

class VerifyPhoneNumber extends SigninEvent {
  final String? phoneNumber; // Making phoneNumber nullable
  const VerifyPhoneNumber(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber]; // Update here as well
}

class SignInWithOTP extends SigninEvent {
  final String? otp; // Making otp nullable
  final String? verificationId; // Making verificationId nullable

  const SignInWithOTP(this.otp, this.verificationId);

  @override
  List<Object?> get props => [otp, verificationId]; // Update here too
}
