part of 'shopregister_bloc.dart';

sealed class ShopregisterState extends Equatable {
  const ShopregisterState();
  
  @override
  List<Object> get props => [];
}

final class ShopregisterInitial extends ShopregisterState {}
