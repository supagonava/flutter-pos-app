import 'package:bloc/bloc.dart';
import 'index.dart';

class PosshopBloc extends Bloc<PosshopEvent, PosshopState> {
  PosshopBloc() : super(InitialState()) {
    // on<PosshopEvent>((event, emit) {});
  }
}
