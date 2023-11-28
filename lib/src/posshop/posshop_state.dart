import 'package:equatable/equatable.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'posshop_model.dart';

abstract class PosshopState extends Equatable {
  PosshopState();
  PosshopState copyWith();

  @override
  List<Object?> get props => [];
}

final class InitialState extends PosshopState {
  InitialState();

  @override
  InitialState copyWith() => InitialState();
}

final class POSSellState extends PosshopState {
  final String shopCode;
  final Shop shop;
  final int tableNumber;
  final List<Product> products;
  final List<Cart> carts;
  final PrinterBluetooth? printer;

  POSSellState({required this.shopCode, required this.tableNumber, required this.products, required this.carts, this.printer, required this.shop});

  @override
  POSSellState copyWith({String? shopCode, int? tableNumber, List<Product>? products, List<Cart>? carts}) =>
      POSSellState(shopCode: shopCode ?? this.shopCode, tableNumber: tableNumber ?? this.tableNumber, products: products ?? this.products, carts: carts ?? this.carts, shop: shop);

  @override
  List<Object?> get props => [tableNumber, products, shopCode, carts];
}

final class SettingPageState extends PosshopState {
  final String? shopCode;
  final List<Product>? products;
  final List<User>? users;

  SettingPageState({this.shopCode, this.products, this.users});

  @override
  SettingPageState copyWith({
    String? shopCode,
    List<Product>? products,
    List<User>? users,
  }) =>
      SettingPageState(shopCode: shopCode ?? this.shopCode, products: products ?? this.products, users: users ?? this.users);

  @override
  List<Object?> get props => [shopCode, products, users];
}

final class PrintingState extends PosshopState {
  final POSSellState prevState;
  final bool finishPrint;

  PrintingState({required this.prevState, required this.finishPrint});

  @override
  PosshopState copyWith() {
    return PrintingState(prevState: prevState, finishPrint: finishPrint);
  }
}
