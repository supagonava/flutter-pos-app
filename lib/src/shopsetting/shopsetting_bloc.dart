import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'shopsetting_event.dart';
part 'shopsetting_state.dart';

class ShopsettingBloc extends Bloc<ShopsettingEvent, ShopsettingState> {
  ShopsettingBloc() : super(ShopsettingInitial()) {
    on<ShopsettingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
