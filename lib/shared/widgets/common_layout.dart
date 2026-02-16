import 'package:everline/routes/routes.dart';
import 'package:everline/shared/widgets/custom_navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CommonLayout extends StatelessWidget {
  final Widget widget;
  final String currentPath;

  const CommonLayout({
    super.key,
    required this.widget,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final isAddMember = currentPath == '/add';
    final isMember = currentPath == '/members';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: ShadTheme.of(context).colorScheme.background,
            border: Border(
              bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            isAddMember ? 'Add Member' : 'Everline',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                !isMember
                    ? ShadIconButton.secondary(
                        onPressed: () => context.go(Routes.members),
                        icon: const Icon(LucideIcons.search),
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                if (!isAddMember) ...[
                  SizedBox(width: 16.0),
                  ShadIconButton.secondary(
                    onPressed: () => context.go('/add'),
                    icon: const Icon(LucideIcons.plus),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavbarWidget(),
      body: widget,
    );
  }
}
