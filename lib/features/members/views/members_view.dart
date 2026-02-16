import 'package:everline/features/members/bloc/members_cubit.dart';
import 'package:everline/features/tree/repository/tree_repository.dart';
import 'package:everline/shared/widgets/common_app_bar.dart';
import 'package:everline/shared/widgets/people_card_widget.dart';
import 'package:everline/shared/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MembersView extends StatefulWidget {
  const MembersView({super.key});

  @override
  State<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Check if we need to focus the search field based on navigation extras
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      if (state.extra != null &&
          state.extra is Map &&
          (state.extra as Map)['focus'] == true) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MembersCubit(repository: TreeRepository())..loadMembers(),
      child: Scaffold(
        appBar: const CommonAppBar(title: 'Family Members', showSearch: false),
        backgroundColor: ShadTheme.of(context).colorScheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchField(focusNode: _searchFocusNode),
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

                        return members.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: Lottie.asset(
                                        'assets/animations/cat-animation.json',
                                      ),
                                    ),
                                    Text(
                                      "Your family tree is feeling lonely! :(",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              )
                            : Skeletonizer(
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
                                      name:
                                          '${member.firstName} ${member.lastName}',
                                      role:
                                          member.occupation ?? 'Family Member',
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
  final FocusNode? focusNode;

  const _SearchField({this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'members_search_field',
      child: TextFieldWidget(
        placeholder: 'Search members...',
        padding: const EdgeInsets.all(16),
        leading: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(LucideIcons.search, size: 16),
        ),
        onChanged: (value) {
          context.read<MembersCubit>().searchMembers(value);
        },
        focusNode: focusNode,
      ),
    );
  }
}
