import 'package:everline/core/service_locator.dart';
import 'package:everline/features/auth/bloc/auth_bloc.dart';
import 'package:everline/features/settings/bloc/settings_cubit.dart';
import 'package:everline/features/settings/widgets/settings_section_header.dart';
import 'package:everline/features/settings/widgets/settings_tile.dart';
import 'package:everline/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit()..loadSettings(),
      child: Scaffold(
        backgroundColor: ShadTheme.of(context).colorScheme.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: ShadTheme.of(context).colorScheme.background,
                elevation: 0,
                pinned: true,
                title: Text(
                  'Settings',
                  style: ShadTheme.of(context).textTheme.h3,
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SettingsSectionHeader(title: 'Theme'),
                    BlocBuilder<SettingsCubit, SettingsState>(
                      builder: (context, state) {
                        if (state is! SettingsLoaded) {
                          return const SizedBox.shrink();
                        }

                        final themeModeText = switch (state.themeMode) {
                          ThemeMode.light => 'Light',
                          ThemeMode.dark => 'Dark',
                          ThemeMode.system => 'System',
                        };

                        return SettingsTile(
                          icon: LucideIcons.palette,
                          title: 'Theme Mode',
                          subtitle: themeModeText,
                          onTap: () => _showThemeDialog(context),
                        );
                      },
                    ),
                    const SettingsSectionHeader(title: 'Appearance & Behavior'),
                    BlocBuilder<SettingsCubit, SettingsState>(
                      builder: (context, state) {
                        if (state is! SettingsLoaded) {
                          return const SizedBox.shrink();
                        }

                        final startupPageText = switch (state.startupPage) {
                          '/home' => 'Home',
                          '/tree' => 'Tree',
                          '/members' => 'Members',
                          _ => 'Home',
                        };

                        return SettingsTile(
                          icon: LucideIcons.house,
                          title: 'Startup Page',
                          subtitle: startupPageText,
                          onTap: () => _showStartupPageDialog(context),
                        );
                      },
                    ),
                    const SettingsSectionHeader(title: 'Account'),
                    SettingsTile(
                      icon: LucideIcons.logOut,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      onTap: () => _showLogoutDialog(context),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final cubit = context.read<SettingsCubit>();

    showShadDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: ShadDialog(
          constraints: const BoxConstraints(maxWidth: 400),
          radius: BorderRadius.circular(25),
          title: const Text('Theme Mode'),
          description: const Text('Select your preferred theme mode'),
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              if (state is! SettingsLoaded) return const SizedBox.shrink();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  _ThemeOption(
                    title: 'Light',
                    icon: LucideIcons.sun,
                    isSelected: state.themeMode == ThemeMode.light,
                    onTap: () {
                      context.read<SettingsCubit>().setThemeMode(
                        ThemeMode.light,
                      );
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                  const SizedBox(height: 8),
                  _ThemeOption(
                    title: 'Dark',
                    icon: LucideIcons.moon,
                    isSelected: state.themeMode == ThemeMode.dark,
                    onTap: () {
                      context.read<SettingsCubit>().setThemeMode(
                        ThemeMode.dark,
                      );
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                  const SizedBox(height: 8),
                  _ThemeOption(
                    title: 'System',
                    icon: LucideIcons.laptop,
                    isSelected: state.themeMode == ThemeMode.system,
                    onTap: () {
                      context.read<SettingsCubit>().setThemeMode(
                        ThemeMode.system,
                      );
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showStartupPageDialog(BuildContext context) {
    final cubit = context.read<SettingsCubit>();

    showShadDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: ShadDialog(
          constraints: const BoxConstraints(maxWidth: 400),
          radius: BorderRadius.circular(25),
          title: const Text('Startup Page'),
          description: const Text('Choose which page to show when app starts'),
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              if (state is! SettingsLoaded) return const SizedBox.shrink();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  _StartupPageOption(
                    title: 'Home',
                    icon: LucideIcons.house,
                    isSelected: state.startupPage == '/home',
                    onTap: () {
                      context.read<SettingsCubit>().setStartupPage('/home');
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                  const SizedBox(height: 8),
                  _StartupPageOption(
                    title: 'Tree',
                    icon: LucideIcons.gitBranch,
                    isSelected: state.startupPage == '/tree',
                    onTap: () {
                      context.read<SettingsCubit>().setStartupPage('/tree');
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                  const SizedBox(height: 8),
                  _StartupPageOption(
                    title: 'Members',
                    icon: LucideIcons.users,
                    isSelected: state.startupPage == '/members',
                    onTap: () {
                      context.read<SettingsCubit>().setStartupPage('/members');
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showShadDialog(
      context: context,
      builder: (dialogContext) => ShadDialog.alert(
        constraints: const BoxConstraints(maxWidth: 400),
        radius: BorderRadius.circular(25),
        title: const Text('Logout'),
        description: const Text('Are you sure you want to logout?'),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          ShadButton(
            child: const Text('Logout'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              getIt<AuthBloc>().add(LoggedOutEvent());
              context.go(Routes.auth);
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? ShadTheme.of(context).colorScheme.primary
                : ShadTheme.of(context).colorScheme.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? ShadTheme.of(context).colorScheme.primary
                  : ShadTheme.of(context).colorScheme.foreground,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: ShadTheme.of(context).textTheme.p.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? ShadTheme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                LucideIcons.check,
                color: ShadTheme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _StartupPageOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StartupPageOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? ShadTheme.of(context).colorScheme.primary
                : ShadTheme.of(context).colorScheme.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? ShadTheme.of(context).colorScheme.primary
                  : ShadTheme.of(context).colorScheme.foreground,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: ShadTheme.of(context).textTheme.p.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? ShadTheme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                LucideIcons.check,
                color: ShadTheme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
