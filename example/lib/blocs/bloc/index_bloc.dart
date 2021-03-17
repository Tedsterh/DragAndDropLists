import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'index_event.dart';
part 'index_state.dart';

class IndexBloc extends Bloc<IndexEvent, IndexState> {
  IndexBloc() : super(LoadingIndex());

  @override
  Stream<IndexState> mapEventToState(
    IndexEvent event,
  ) async* {
    if (event is GetIndexs) {
      yield UpdatingIndex(
        List.generate(10, (index) => index),
      );
    }
  }
}
