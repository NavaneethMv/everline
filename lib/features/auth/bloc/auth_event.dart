part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Building events

class EmailChangedEvent extends AuthEvent {
  final String email;

  EmailChangedEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class PassWordChangedEvent extends AuthEvent {
  final String password;

  PassWordChangedEvent({required this.password});

  @override
  List<Object?> get props => [password];
}

class TermsAcceptedChangedEvent extends AuthEvent {
  final bool isTermsAccepted;

  TermsAcceptedChangedEvent({required this.isTermsAccepted});

  @override
  List<Object?> get props => [isTermsAccepted];
}

// Action events

class LoginEvent extends AuthEvent {
  @override
  List<Object?> get props => [];
}

class LoggedOutEvent extends AuthEvent {}
