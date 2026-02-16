import 'package:everline/features/members/bloc/members_cubit.dart';
import 'package:everline/features/tree/repository/tree_repository.dart';
import 'package:everline/shared/widgets/people_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MembersView extends StatelessWidget {
  const MembersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MembersCubit(repository: TreeRepository())..loadMembers(),
      child: Scaffold(
        backgroundColor: ShadTheme.of(context).colorScheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Family Members',
                  style: ShadTheme.of(context).textTheme.h3,
                ),
                const SizedBox(height: 16),
                _SearchField(),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<MembersCubit, MembersState>(
                    builder: (context, state) {
                      if (state is MembersError) {
                        return Center(child: Text('Error: ${state.message}'));
                      }

                      if (state is MembersLoaded || state is MembersLoading) {
                        final members = state is MembersLoaded
                            ? state.filteredMembers
                            : List.generate(
                                10,
                                (_) => (null as dynamic), // Dummy for skeleton
                              );

                        return Skeletonizer(
                          enabled: state is MembersLoading,
                          child: ListView.separated(
                            itemCount: state is MembersLoading
                                ? 10
                                : members.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              if (state is MembersLoading) {
                                return const PeopleCardWidget(
                                  name: 'Loading Name',
                                  role: 'Family Member',
                                  avatarUrl: '',
                                );
                              }

                              final member = members[index];
                              return PeopleCardWidget(
                                name: '${member.firstName} ${member.lastName}',
                                role: member.occupation ?? 'Family Member',
                                avatarUrl: member.profileImageUrl,
                              );
                            },
                          ),
                        );
                      }

                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShadInput(
      placeholder: const Text('Search members...'),
      onChanged: (value) {
        context.read<MembersCubit>().searchMembers(value);
      },
      leading: const Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(LucideIcons.search, size: 16),
      ),
    );
  }
}
