import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:everline/features/tree/models/family_tree_node.dart';
import 'package:everline/features/tree/repository/tree_repository.dart';

part 'members_state.dart';

class MembersCubit extends Cubit<MembersState> {
  final TreeRepository _repository;

  MembersCubit({required TreeRepository repository})
    : _repository = repository,
      super(MembersInitial());

  Future<void> loadMembers() async {
    emit(MembersLoading());
    try {
      final membersData = await _repository.fetchMembers();
      final members = membersData
          .map((m) => FamilyTreeNode.fromJson(m))
          .toList();

      emit(MembersLoaded(members: members, filteredMembers: members));
    } catch (e) {
      emit(MembersError(e.toString()));
    }
  }

  void searchMembers(String query) {
    if (state is MembersLoaded) {
      final loadedState = state as MembersLoaded;
      final q = query.toLowerCase();

      if (q.isEmpty) {
        emit(loadedState.copyWith(filteredMembers: loadedState.members));
        return;
      }

      final filtered = loadedState.members.where((m) {
        final name = '${m.firstName} ${m.lastName}'.toLowerCase();
        final nickname = (m.nickname ?? '').toLowerCase();
        return name.contains(q) || nickname.contains(q);
      }).toList();

      emit(loadedState.copyWith(filteredMembers: filtered));
    }
  }
}
