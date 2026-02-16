import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:everline/features/tree/models/family_tree_node.dart';
import 'package:everline/features/tree/repository/tree_repository.dart';

part 'tree_event.dart';
part 'tree_state.dart';

class TreeBloc extends Bloc<TreeEvent, TreeState> {
  final TreeRepository _repository;

  TreeBloc({required TreeRepository repository})
    : _repository = repository,
      super(TreeInitial()) {
    on<LoadTree>(_onLoadTree);
  }

  Future<void> _onLoadTree(LoadTree event, Emitter<TreeState> emit) async {
    emit(TreeLoading());
    try {
      final members = await _repository.fetchMembers();
      final relations = await _repository.fetchRelationships();

      final parentMap = <String, List<String>>{};
      final spouseMap = <String, String>{};

      for (var rel in relations) {
        final type = rel['relationship_type']?.toString().toLowerCase() ?? '';
        final member1 = rel['member1_id'];
        final member2 = rel['member2_id'];

        log("Processing: member1: $member1, member2: $member2, type: $type");

        if (type == 'parent') {
          // member1 is Parent, member2 is Child
          parentMap[member2] ??= [];
          parentMap[member2]!.add(member1);
          log("Added parent $member1 to child $member2");
        } else if (type == 'child') {
          // member1 is Child, member2 is Parent
          parentMap[member1] ??= [];
          parentMap[member1]!.add(member2);
          log("Added parent $member2 to child $member1");
        } else if (type == 'spouse') {
          spouseMap[member1] = member2;
          spouseMap[member2] = member1;
        }
      }

      log("Final parent map: $parentMap");

      final nodes = members.map((m) {
        final id = m['id'] as String;
        // Remove duplicate parent IDs by converting to Set and back to List
        final parents = (parentMap[id] ?? []).toSet().toList();
        log("Node $id (${m['first_name']}) has parents: $parents");
        return FamilyTreeNode.fromJson(
          m,
          parentIds: parents,
          partnerId: spouseMap[id],
        );
      }).toList();

      log("Total nodes created: ${nodes.length}");
      emit(TreeLoaded(nodes, relations));
    } catch (e) {
      emit(TreeError(e.toString()));
    }
  }
}
