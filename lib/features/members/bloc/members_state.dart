part of 'members_cubit.dart';

abstract class MembersState extends Equatable {
  const MembersState();

  @override
  List<Object> get props => [];
}

class MembersInitial extends MembersState {}

class MembersLoading extends MembersState {}

class MembersLoaded extends MembersState {
  final List<FamilyTreeNode> members;
  final List<FamilyTreeNode> filteredMembers;

  const MembersLoaded({required this.members, required this.filteredMembers});

  @override
  List<Object> get props => [members, filteredMembers];

  MembersLoaded copyWith({
    List<FamilyTreeNode>? members,
    List<FamilyTreeNode>? filteredMembers,
  }) {
    return MembersLoaded(
      members: members ?? this.members,
      filteredMembers: filteredMembers ?? this.filteredMembers,
    );
  }
}

class MembersError extends MembersState {
  final String message;

  const MembersError(this.message);

  @override
  List<Object> get props => [message];
}
