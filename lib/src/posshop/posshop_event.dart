import 'package:dimsummaster/src/posshop/posshop_model.dart';
import 'package:equatable/equatable.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class PosshopEvent extends Equatable {
  const PosshopEvent();

  @override
  List<Object?> get props => [];
}

// Setting Event
final class OpenPosPageEvent extends PosshopEvent {
  final String? shopCode;
  final int? tableNo;
  const OpenPosPageEvent({this.shopCode, this.tableNo});

  @override
  List<Object?> get props => [shopCode];
}

final class OpenSettingPageEvent extends PosshopEvent {
  final String? shopCode;
  const OpenSettingPageEvent(this.shopCode);
  @override
  List<Object?> get props => [shopCode];
}

final class UpdateUsersRoleInShopEvent extends PosshopEvent {
  final List<User>? users;
  const UpdateUsersRoleInShopEvent(this.users);

  @override
  List<Object?> get props => [users];
}

final class UpdateProductsInShopEvent extends PosshopEvent {
  final List<Product>? products;
  final String shopCode;
  final bool isSubmit;

  const UpdateProductsInShopEvent({this.products, required this.shopCode, required this.isSubmit});

  @override
  List<Object?> get props => [products];
}

// POS Event
final class SwitchTableEvent extends PosshopEvent {
  final int tableNumber;
  const SwitchTableEvent(this.tableNumber);

  @override
  List<Object?> get props => [tableNumber];
}

final class UpdateTableCartsEvent extends PosshopEvent {
  final String shopCode;
  final int tableNumber;
  final List<Cart> carts;
  const UpdateTableCartsEvent({required this.shopCode, required this.tableNumber, required this.carts});

  @override
  List<Object?> get props => [shopCode, tableNumber, carts];
}

final class SubmitPurchaseOrderEvent extends PosshopEvent {
  final String shopCode;
  final String billingNo;
  final int tableNumber;
  final List<Cart> carts;
  final PrinterBluetooth? printer;
  const SubmitPurchaseOrderEvent({required this.shopCode, required this.tableNumber, required this.carts, this.printer, required this.billingNo});
  @override
  List<Object?> get props => [shopCode, tableNumber, carts];
}
