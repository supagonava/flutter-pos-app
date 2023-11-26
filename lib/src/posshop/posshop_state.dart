import 'package:equatable/equatable.dart';

sealed class PosshopState extends Equatable {
  const PosshopState();

  @override
  List<Object?> get props => [];
}

final class InitialState extends PosshopState {}

final class POSSellState extends PosshopState {
  final String? shopCode;
  final int? tableNumber;
  final List<dynamic>? products;

  const POSSellState(this.tableNumber, this.products, this.shopCode);

  @override
  List<Object?> get props => [tableNumber, products, shopCode];
}

final class SettingPageState extends PosshopState {
  final String? shopCode;
  final List<dynamic>? products;
  final List<dynamic>? users;

  const SettingPageState(this.shopCode, this.products, this.users);
  @override
  List<Object?> get props => [shopCode, products, users];
}
