part of 'index_bloc.dart';

abstract class IndexState extends Equatable {
  const IndexState();
  
  @override
  List<Object> get props => [];
}

class LoadingIndex extends IndexState {}

class UpdatingIndex extends IndexState {
  final List<int> indexs;

  UpdatingIndex(this.indexs);

  @override
  List<Object> get props => [indexs];
}

class FailedIndex extends IndexState {}