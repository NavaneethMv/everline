import 'dart:async';

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
    on<LoginEvent>(_login);
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

  Future<void> _login(LoginEvent event, Emitter<AuthState> emit) async {
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
