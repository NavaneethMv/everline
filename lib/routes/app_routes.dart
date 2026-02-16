import 'package:everline/core/service_locator.dart';
import 'package:everline/features/add/bloc/add_cubit.dart';
import 'package:everline/features/add/views/add_view.dart';
import 'package:everline/features/auth/bloc/auth_bloc.dart';
import 'package:everline/features/auth/views/auth_view.dart';
import 'package:everline/features/home/views/home_view.dart';
import 'package:everline/features/members/views/members_view.dart';
import 'package:everline/features/settings/views/settings_view.dart';
import 'package:everline/features/tree/views/tree_view.dart';
import 'package:everline/routes/routes.dart';
import 'package:everline/shared/widgets/common_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.auth,
  routes: [
    GoRoute(
      path: Routes.auth,
      name: 'auth',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<AuthBloc>(),
        child: const AuthView(),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return CommonLayout(widget: child, currentPath: state.uri.path);
      },
      routes: [
        GoRoute(
          path: Routes.home,
          name: 'home',
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: Routes.tree,
          name: 'tree',
          builder: (context, state) => const TreeView(),
        ),
        GoRoute(
          path: Routes.members,
          name: 'members',
          builder: (context, state) => const MembersView(),
        ),
        GoRoute(
          path: Routes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsView(),
        ),
        GoRoute(
          path: Routes.add,
          name: 'add',
          builder: (context, state) => BlocProvider(
            create: (context) => AddCubit(),
            child: const AddView(),
          ),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Page not found'))),
);
