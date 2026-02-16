import 'package:everline/features/auth/bloc/auth_bloc.dart';
import 'package:everline/shared/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AuthCardWidget extends StatelessWidget {
  const AuthCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      radius: BorderRadius.all(Radius.circular(16)),
      title: const Text('Sign in to your account'),
      description: Text(
        "Sign in to your account and start viewing your everline",
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return ShadCheckbox(
                value: state.isTermsAccepted,
                label: const Text('Accept terms and conditions'),
                onChanged: (value) {
                  context.read<AuthBloc>().add(
                    TermsAcceptedChangedEvent(isTermsAccepted: value),
                  );
                },
              );
            },
          ),
          SizedBox(height: 16),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return ShadButton(
                height: 50,
                width: double.infinity,
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
                    : Text(
                        'login',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
              );
            },
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          TextFieldWidget(
            padding: EdgeInsets.all(16),
            label: 'Email',
            placeholder: 'Enter your email',
            onChanged: (value) {
              context.read<AuthBloc>().add(EmailChangedEvent(email: value));
            },
          ),
          const SizedBox(height: 8),
          TextFieldWidget(
            padding: EdgeInsets.all(16),
            label: 'Password',
            placeholder: 'Enter your password',
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
