import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

// Using AsyncNotifier as replacement for StateNotifier for async state
class UserNotifier extends AsyncNotifier<UserProfile?> {
  static const _kidSessionKey = 'anjra_kid_session';
  
  @override
  FutureOr<UserProfile?> build() async {
    // 1. Check Authenticated User (Parent)
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      return _fetchProfile(user.id);
    }
    
    // 2. Check Persisted Kid Session
    final prefs = await SharedPreferences.getInstance();
    final kidId = prefs.getString(_kidSessionKey);
    if (kidId != null) {
       return _fetchProfile(kidId);
    }

    return null;
  }

  Future<UserProfile?> _fetchProfile(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserProfile.fromJson(data);
    } catch (e) {
      // If fetch fails (e.g. user deleted), clear session
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kidSessionKey);
      return null;
    }
  }

  Future<void> refreshProfile() async {
    // Capture current data before setting to loading, to support virtual sessions
    final currentProfile = state.value;
    
    // Reload state
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = Supabase.instance.client.auth.currentUser;
      // Use authenticated user OR fallback to the previously loaded profile (Kid) OR prefs
      String? userId = user?.id ?? currentProfile?.id;
      
      if (userId == null) {
         final prefs = await SharedPreferences.getInstance();
         userId = prefs.getString(_kidSessionKey);
      }

      if (userId == null) return null;
      return _fetchProfile(userId);
    });
  }

  Future<void> setKidUser(UserProfile kid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kidSessionKey, kid.id);
    state = AsyncData(kid);
  }

  Future<void> setMockUser(UserProfile user) async {
    // For test mode, we just set the state directly without persistence checks or Supabase
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kidSessionKey);
    state = const AsyncData(null);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, UserProfile?>(() {
  return UserNotifier();
});
