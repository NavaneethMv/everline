part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  final String email;
  final String password;
  final String? errorMessage;
  final AuthStatus status;
  final bool isTermsAccepted;

  const AuthState({
    this.email = '',
    this.password = '',
    this.errorMessage,
    this.status = AuthStatus.initial,
    this.isTermsAccepted = false,
  });

  bool get isValid =>
      email.isNotEmpty && email.contains('@') && password.length >= 6;

  AuthState copyWith({
    String? email,
    String? password,
    String? errorMessage,
    bool? isSubmitting,
    AuthStatus? status,
    bool? isTermsAccepted,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: errorMessage,
      status: status ?? this.status,
      isTermsAccepted: isTermsAccepted ?? this.isTermsAccepted,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    errorMessage,
    status,
    isTermsAccepted,
  ];
}
