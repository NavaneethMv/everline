import 'package:everline/core/service_locator.dart';
import 'package:everline/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient client = getIt<SupabaseService>().client;

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signUp(email: email, password: password);
    return response;
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  Session? getCurrentSession() {
    return client.auth.currentSession;
  }

  bool isUserSignedIn() {
    return client.auth.currentSession != null;
  }

  Future<void> resetPassword({required String email}) async {
    await client.auth.resetPasswordForEmail(email);
  }

  Future<UserResponse> updatePassword({required String newPassword}) async {
    final response = await client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    return response;
  }

  Future<UserResponse> updateEmail({required String newEmail}) async {
    final response = await client.auth.updateUser(
      UserAttributes(email: newEmail),
    );
    return response;
  }

  Stream<AuthState> authStateChanges() {
    return client.auth.onAuthStateChange;
  }

  Future<void> deleteUser() async {
    final user = client.auth.currentUser;
    if (user != null) {
      await client.rpc('delete_user');
    }
  }

  Future<AuthResponse> refreshSession() async {
    final response = await client.auth.refreshSession();
    return response;
  }
}
