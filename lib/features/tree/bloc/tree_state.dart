part of 'tree_bloc.dart';

abstract class TreeState extends Equatable {
  const TreeState();

  @override
  List<Object> get props => [];
}

class TreeInitial extends TreeState {}

class TreeLoading extends TreeState {}

class TreeLoaded extends TreeState {
  final List<FamilyTreeNode> nodes;

  const TreeLoaded(this.nodes);

  @override
  List<Object> get props => [nodes];
}

class TreeError extends TreeState {
  final String message;

  const TreeError(this.message);

  @override
  List<Object> get props => [message];
}
