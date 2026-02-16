import 'package:everline/features/home/bloc/home_cubit.dart';
import 'package:everline/features/tree/models/family_tree_node.dart';
import 'package:everline/features/tree/repository/tree_repository.dart';
import 'package:everline/shared/widgets/home_grid_widget.dart';
import 'package:everline/shared/widgets/people_card_widget.dart';
import 'package:everline/shared/widgets/stat_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:everline/features/home/widgets/member_growth_chart.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeCubit(repository: TreeRepository())..loadHomeData(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final isLoading = state is HomeLoading;

              String totalMembers = '1234';
              String upcomingBirthdays = '5';
              Map<DateTime, int> monthlyGrowth = {}; // Dummy/Empty for skeleton

              List<FamilyTreeNode> recentMembersList = List.generate(
                4,
                (index) => FamilyTreeNode(
                  id: 'iso',
                  memberIdString: '1',
                  firstName: 'Loading',
                  lastName: 'User',
                  gender: 'male',
                ),
              );

              if (state is HomeLoaded) {
                totalMembers = state.totalMembers.toString();
                upcomingBirthdays = state.upcomingBirthdays.toString();
                recentMembersList = state.recentMembers;
                monthlyGrowth = state.monthlyGrowth;
              }

              return Skeletonizer(
                enabled: isLoading,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeGridWidget(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomCard(
                          title: 'Total Members',
                          value: totalMembers,
                          subtitle: 'Family size',
                          icon: LucideIcons.users,
                        ),
                        CustomCard(
                          title: 'Birthdays',
                          value: upcomingBirthdays,
                          subtitle: 'Upcoming',
                          icon: LucideIcons.cake,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (monthlyGrowth.isNotEmpty || isLoading) ...[
                      SizedBox(
                        height: 300,
                        child: MemberGrowthChart(
                          monthlyGrowth: isLoading
                              ? {
                                  DateTime.now().subtract(
                                    const Duration(days: 150),
                                  ): 10,
                                  DateTime.now().subtract(
                                    const Duration(days: 120),
                                  ): 15,
                                  DateTime.now().subtract(
                                    const Duration(days: 90),
                                  ): 12,
                                  DateTime.now().subtract(
                                    const Duration(days: 60),
                                  ): 20,
                                  DateTime.now().subtract(
                                    const Duration(days: 30),
                                  ): 25,
                                  DateTime.now(): 30,
                                }
                              : monthlyGrowth,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    ShadCard(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            "Newest members",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Icon(
                            LucideIcons.clock,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          spacing: 8,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: recentMembersList.isEmpty
                              ? [const Text("No members found")]
                              : recentMembersList
                                    .map(
                                      (m) => PeopleCardWidget(
                                        avatarUrl: m.profileImageUrl,
                                        name: '${m.firstName} ${m.lastName}',
                                        role: m.occupation ?? 'Family Member',
                                      ),
                                    )
                                    .toList(),
                        ),
                      ),
                    ),
                    // DraggableGridWidget(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
