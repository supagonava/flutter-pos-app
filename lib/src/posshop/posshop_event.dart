import 'package:equatable/equatable.dart';

abstract class PosshopEvent extends Equatable {
  const PosshopEvent();

  @override
  List<Object?> get props => [];
}

// Setting Event
final class SwitchShopEvent extends PosshopEvent {
  final String? shopCode;
  const SwitchShopEvent(this.shopCode);

  @override
  List<Object?> get props => [shopCode];
}

final class UpdateUsersRoleInShopEvent extends PosshopEvent {
  final List<dynamic>? users;
  const UpdateUsersRoleInShopEvent(this.users);

  @override
  List<Object?> get props => [users];
}

final class UpdateProductsInShopEvent extends PosshopEvent {
  final List<dynamic>? products;
  final String shopCode;

  const UpdateProductsInShopEvent(this.products, this.shopCode);

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
  final int tableNumber;
  final List<dynamic> products;
  const UpdateTableCartsEvent(this.tableNumber, this.products);

  @override
  List<Object?> get props => [products];
}

final class SubmitPurchaseOrderEvent extends PosshopEvent {
  final int tableNumber;
  final List<dynamic> products;
  const SubmitPurchaseOrderEvent(this.tableNumber, this.products);

  @override
  List<Object?> get props => [products];
}
