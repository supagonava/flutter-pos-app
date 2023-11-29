part of 'shopsetting_bloc.dart';

sealed class ShopsettingState extends Equatable {
  const ShopsettingState();
  
  @override
  List<Object> get props => [];
}

final class ShopsettingInitial extends ShopsettingState {}
