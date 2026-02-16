import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:everline/core/service_locator.dart';
import 'package:everline/features/auth/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = getIt<AuthRepository>();
  AuthBloc() : super(AuthState()) {
    on<EmailChangedEvent>(_emailChanged);
    on<PassWordChangedEvent>(_passwordChanged);
    on<TermsAcceptedChangedEvent>(_termsAcceptedChanged);
    on<LoggedOutEvent>(_loggedOut);
    on<LoginEvent>(_login);
  }

  Future<void> _loggedOut(LoggedOutEvent event, Emitter<AuthState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _authRepository.signOut();
      emit(const AuthState());
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.failure));
    }
  }

  FutureOr<void> _emailChanged(
    EmailChangedEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(email: event.email));
  }

  FutureOr<void> _passwordChanged(
    PassWordChangedEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  FutureOr<void> _termsAcceptedChanged(
    TermsAcceptedChangedEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(isTermsAccepted: event.isTermsAccepted));
  }

  Future<void> _login(LoginEvent event, Emitter<AuthState> emit) async {
    if (!state.isTermsAccepted) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Please accept terms and conditions',
        ),
      );
      return;
    }
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final response = await _authRepository.signInWithEmail(
        email: state.email,
        password: state.password,
      );
      if (response.user != null) {
        emit(state.copyWith(isSubmitting: false, status: AuthStatus.success));
      } else {
        emit(
          state.copyWith(
            isSubmitting: false,
            status: AuthStatus.failure,
            errorMessage: 'Invalid Credentials',
          ),
        );
      }
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: AuthStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }
}
