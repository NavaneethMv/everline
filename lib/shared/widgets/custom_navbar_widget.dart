import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomNavbarWidget extends StatefulWidget {
  const CustomNavbarWidget({super.key});

  @override
  State<CustomNavbarWidget> createState() => _CustomNavbarWidgetState();
}

class _CustomNavbarWidgetState extends State<CustomNavbarWidget> {
  @override
  Widget build(BuildContext context) {
    final String currentPath = GoRouterState.of(context).uri.path;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final inactiveColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.5);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 70 + bottomPadding,
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context: context,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            route: '/home',
            currentPath: currentPath,
            primaryColor: primaryColor,
            inactiveColor: inactiveColor,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.account_tree_outlined,
            activeIcon: Icons.account_tree,
            label: 'Tree',
            route: '/tree',
            currentPath: currentPath,
            primaryColor: primaryColor,
            inactiveColor: inactiveColor,
          ),
          _buildCenterButton(context, currentPath, primaryColor),
          _buildNavItem(
            context: context,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Members',
            route: '/members',
            currentPath: currentPath,
            primaryColor: primaryColor,
            inactiveColor: inactiveColor,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
            route: '/settings',
            currentPath: currentPath,
            primaryColor: primaryColor,
            inactiveColor: inactiveColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required String currentPath,
    required Color primaryColor,
    required Color inactiveColor,
  }) {
    final isSelected = currentPath.startsWith(route);

    return Expanded(
      child: InkWell(
        onTap: () => context.go(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? primaryColor : inactiveColor,
              size: 26,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? primaryColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(
    BuildContext context,
    String currentPath,
    Color primaryColor,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () => context.go('/add'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
