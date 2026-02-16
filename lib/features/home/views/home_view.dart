import 'package:everline/features/home/bloc/home_cubit.dart';
import 'package:everline/features/tree/models/family_tree_node.dart';
import 'package:everline/features/tree/repository/tree_repository.dart';
import 'package:everline/shared/widgets/common_app_bar.dart';
import 'package:everline/shared/widgets/home_grid_widget.dart';
import 'package:everline/shared/widgets/people_card_widget.dart';
import 'package:everline/shared/widgets/stat_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
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
      child: Scaffold(
        appBar: const CommonAppBar(title: 'Everline'),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                final isLoading = state is HomeLoading;

                String totalMembers = '1234';
                String upcomingBirthdays = '5';
                Map<DateTime, int> monthlyGrowth = {};
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
                            title: 'Members',
                            value: totalMembers,
                            subtitle: 'Family size',
                            icon: LucideIcons.users,
                          ),
                          CustomCard(
                            title: 'Birthdays',
                            value: upcomingBirthdays,
                            subtitle: 'Upcoming',
                            icon: LucideIcons.cake,
                            onTap: () => _showBirthdaysSheet(
                              context,
                              (state as HomeLoaded).upcomingBirthdayMembers,
                            ),
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
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
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
                                ? [
                                    const SizedBox(height: 12),
                                    Center(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: Lottie.asset(
                                              'assets/animations/cat-animation.json',
                                            ),
                                          ),
                                          Text(
                                            'No members added yet',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
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
      ),
    );
  }

  void _showBirthdaysSheet(BuildContext context, List<FamilyTreeNode> members) {
    showShadSheet(
      side: ShadSheetSide.bottom,
      context: context,
      builder: (context) {
        return ShadSheet(
          closeIcon: GestureDetector(
            onTap: () => context.pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8,
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                child: Icon(
                  LucideIcons.x,
                  color: Theme.of(context).colorScheme.shadow,
                ),
              ),
            ),
          ),
          useSafeArea: false,
          removeBorderRadiusWhenTiny: false,
          radius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          crossAxisAlignment: CrossAxisAlignment.start,
          title: const Text('Upcoming Birthdays'),
          description: const Text(
            'Members celebrating their birthday in the next 30 days',
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: members.isEmpty
                ? const Center(child: Text('No upcoming birthdays'))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: members.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final dob = member.dob!;
                      final now = DateTime.now();
                      final nextBday = DateTime(now.year, dob.month, dob.day);
                      final age =
                          now.year -
                          dob.year +
                          (nextBday.isBefore(now) ? 1 : 0);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: member.profileImageUrl != null
                              ? NetworkImage(member.profileImageUrl!)
                              : null,
                          child: member.profileImageUrl == null
                              ? Text(member.firstName[0])
                              : null,
                        ),
                        title: Text('${member.firstName} ${member.lastName}'),
                        subtitle: Text(
                          'Turning $age on ${dob.day}/${dob.month}',
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
