import 'package:everline/features/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AuthCardWidget extends StatelessWidget {
  const AuthCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      title: const Text('Sign in to your account'),
      description: Text(
        "Sign in to your account and start viewing your everline",
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShadCheckbox(
            value: true,
            label: const Text('Accept terms and conditions'),
          ),
          SizedBox(height: 16),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return ShadButton(
                leading: state.status == AuthStatus.loading
                    ? SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ShadTheme.of(
                            context,
                          ).colorScheme.primaryForeground,
                        ),
                      )
                    : null,
                enabled: state.status != AuthStatus.loading,
                onPressed: () => context.read<AuthBloc>().add(LoginEvent()),
                child: state.status == AuthStatus.loading
                    ? Text("Please wait")
                    : Text('login'),
              );
            },
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          ShadInputFormField(
            label: const Text('Email'),
            onChanged: (value) {
              context.read<AuthBloc>().add(EmailChangedEvent(email: value));
            },
          ),
          const SizedBox(height: 8),
          ShadInputFormField(
            label: const Text('Password'),
            obscureText: true,
            onChanged: (value) {
              context.read<AuthBloc>().add(
                PassWordChangedEvent(password: value),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
