import 'package:everline/shared/widgets/home_grid_widget.dart';
import 'package:everline/shared/widgets/people_card_widget.dart';
import 'package:everline/shared/widgets/stat_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeGridWidget(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                  title: 'Total Members',
                  value: '1,234',
                  subtitle: '+12% from last month',
                  icon: LucideIcons.users,
                ),
                CustomCard(
                  title: 'Upcoming Events',
                  value: '24',
                  icon: LucideIcons.folderOpen,
                ),
                CustomCard(
                  title: 'New Signups',
                  value: '76',
                  subtitle: '+5% from last month',
                  icon: LucideIcons.userPlus,
                ),
                CustomCard(
                  title: 'New Signups',
                  value: '76',
                  subtitle: '+5% from last month',
                  icon: LucideIcons.userPlus,
                ),
              ],
            ),
            SizedBox(height: 20),
            ShadCard(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Newest members",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    LucideIcons.users,
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
                  children: [
                    PeopleCardWidget(
                      avatarUrl:
                          'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
                      name: 'John Doe',
                      role: 'Software Engineer',
                    ),
                    PeopleCardWidget(
                      avatarUrl:
                          'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
                      name: 'Jane Smith',
                      role: 'Product Manager',
                    ),
                    PeopleCardWidget(
                      avatarUrl:
                          'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
                      name: 'Mary Johnson',
                      role: 'Product Manager',
                    ),
                    PeopleCardWidget(
                      avatarUrl:
                          'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
                      name: 'Navin',
                      role: 'Product Manager',
                    ),
                  ],
                ),
              ),
            ),
            // DraggableGridWidget(),
          ],
        ),
      ),
    );
  }
}
