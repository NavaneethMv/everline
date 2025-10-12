part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  final String email;
  final String password;
  final String? errorMessage;
  final AuthStatus status;

  const AuthState({
    this.email = '',
    this.password = '',
    this.errorMessage,
    this.status = AuthStatus.initial,
  });

  bool get isValid =>
      email.isNotEmpty && email.contains('@') && password.length >= 6;

  AuthState copyWith({
    String? email,
    String? password,
    String? errorMessage,
    bool? isSubmitting,
    AuthStatus? status,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: errorMessage,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [email, password, errorMessage, status];
}
