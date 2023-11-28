import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'shopregister_event.dart';
part 'shopregister_state.dart';

class ShopregisterBloc extends Bloc<ShopregisterEvent, ShopregisterState> {
  ShopregisterBloc() : super(ShopregisterInitial()) {
    on<ShopregisterEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
