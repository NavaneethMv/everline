import 'package:everline/features/auth/bloc/auth_bloc.dart';
import 'package:everline/features/auth/widgets/auth_card_widget.dart';
import 'package:everline/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Login failed'),
              description: Text(
                state.errorMessage ?? 'An unknown error occurred',
              ),
              alignment: Alignment.topCenter,
            ),
          );
        } else if (state.status == AuthStatus.success) {
          ShadToaster.of(context).show(
            ShadToast(
              title: const Text('Logged in successfully'),
              alignment: Alignment.topCenter,
            ),
          );
          context.go(Routes.home);
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Everline',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Where you connect with your roots.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),
                AuthCardWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
