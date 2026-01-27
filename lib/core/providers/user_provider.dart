import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Added for TEST_MODE
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:anjra/features/auth/repository/profile_repository.dart';

// The global user state
class AppUser {
  final Map<String, dynamic> profile;
  final bool isKid;

  AppUser({required this.profile, required this.isKid});

  String get id => profile['id'];
  String get name => profile['full_name'] ?? 'User';
  String get username => profile['username'] ?? '';
  bool get isParent => profile['is_parent'] ?? false;
  double get balance => (profile['balance'] as num?)?.toDouble() ?? 0.0;
  String get pin => profile['pin'] ?? ''; // Added PIN accessor

  Map<String, dynamic> toJson() => {
    'profile': profile,
    'isKid': isKid,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      profile: Map<String, dynamic>.from(json['profile']),
      isKid: json['isKid'] ?? false,
    );
  }
}

class UserNotifier extends AsyncNotifier<AppUser?> {
  static AppUser? _overrideUser;
  
  @override
  Future<AppUser?> build() async {
    // 1. Check memory override
    if (_overrideUser != null) return _overrideUser;

    // TEST MODE: Check Local Mock Parent
    if (dotenv.env['TEST_MODE'] == 'true') {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('is_test_parent_logged_in') == true) {
         final name = prefs.getString('test_parent_name') ?? 'Test Parent';
         _overrideUser = AppUser(
           profile: {
             'id': '00000000-0000-0000-0000-000000000000',
             'full_name': name,
             'is_parent': true,
             'username': 'testparent',
             'balance': 0, // Mock balance
           },
           isKid: false,
         );
         return _overrideUser;
      }
    }

    // 2. Check Supabase Auth (Persistence for Parents)
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Parent Logged In (Real Auth)
        final repo = ref.read(profileRepositoryProvider);
        final profile = await repo.getCurrentProfile();
        
        // Safety: If we are a parent, ensure we don't have a stale Kid session
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('app_user_session')) {
           await prefs.remove('app_user_session');
        }
        
        return _overrideUser ?? AppUser(profile: profile, isKid: false);
      }
    } catch (e) {
      print('User build error: $e');
    }

    // 3. Check Local Storage (Persistence for Kids) - FALLBACK
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('app_user_session');
    if (jsonStr != null) {
      try {
        final user = AppUser.fromJson(jsonDecode(jsonStr));
        _overrideUser = user;
        return user;
      } catch (e) {
        prefs.remove('app_user_session');
      }
    }
    
    return _overrideUser;
  }

  Future<void> refreshProfile() async {
    // Check if we are currently in "Kid Mode"
    final currentUser = state.asData?.value;
    final isKid = currentUser?.isKid ?? false;
    final userId = currentUser?.id;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      
      AppUser? newUser;
      
      if (isKid && userId != null) {
        final profile = await repo.getProfile(userId);
        if (profile == null) throw Exception('Profile not found');
        newUser = AppUser(profile: profile, isKid: true);
      } else {
        final profile = await repo.getCurrentProfile();
        newUser = AppUser(profile: profile, isKid: false);
      }
      
      // Update override and persist
      _overrideUser = newUser;
      _persistUser(newUser);
      
      return newUser;
    });
  }

  // Called when Kid logs in via PIN
  void setKidUser(Map<String, dynamic> kidProfile) {
    _overrideUser = AppUser(profile: kidProfile, isKid: true);
    _persistUser(_overrideUser!);
    state = AsyncValue.data(_overrideUser);
  }

  Future<void> _persistUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_user_session', jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
     await Supabase.instance.client.auth.signOut();
     final prefs = await SharedPreferences.getInstance();
     await prefs.remove('app_user_session');
     
     // Clear Test Mode Session
     await prefs.remove('is_test_parent_logged_in');
     await prefs.remove('test_parent_name');
     
     _overrideUser = null;
     state = const AsyncValue.data(null);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, AppUser?>(UserNotifier.new);
