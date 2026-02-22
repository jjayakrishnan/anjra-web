import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

// Provider for specific User Profile stream (optional, will implement later)
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // Parent Sign Up
  Future<AuthResponse> signUpParent({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'is_parent': true, // Meta data for trigger (or handle in profile creation)
      },
    );
    // Note: The 'profiles' table should be populated via a Supabase Database Trigger
    // roughly: NEW.id, NEW.raw_user_meta_data->>'full_name', etc.
    return response;
  }

  // Parent Sign In
  Future<AuthResponse> signInParent({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Reset Password for Parent
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Kid Sign In (Simplified: Using a "Quick Code" or QR which maps to email/pass strictly? 
  // OR actually implementing a custom auth flow?
  // For MVP, simplistic approach: Kids also have email/pass managed by parent?
  // BETTER: Parent creates Kid (which creates a user in background).
  // OR: Kid user is just a row in 'profiles' and we use a logical login?
  // Let's stick to: Everyone is a Supabase User for security. Parent creates kid account with a generated email like `kid_username@anjra.app`.
  
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}
