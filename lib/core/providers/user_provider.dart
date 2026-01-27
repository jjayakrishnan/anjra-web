import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

// Using AsyncNotifier as replacement for StateNotifier for async state
class UserNotifier extends AsyncNotifier<UserProfile?> {
  
  @override
  FutureOr<UserProfile?> build() async {
    // Initial load logic
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      return _fetchProfile(user.id);
    }
    return null;
  }

  Future<UserProfile?> _fetchProfile(String userId) async {
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(data);
  }

  Future<void> refreshProfile() async {
    // Reload state
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = Supabase.instance.client.auth.currentUser;
      final currentProfile = state.value;
      final userId = user?.id ?? currentProfile?.id;
      
      if (userId == null) return null;
      return _fetchProfile(userId);
    });
  }

  void setKidUser(UserProfile kid) {
    state = AsyncData(kid);
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    state = const AsyncData(null);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, UserProfile?>(() {
  return UserNotifier();
});
