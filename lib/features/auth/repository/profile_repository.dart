import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getCurrentProfile();
});

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  Future<Map<String, dynamic>> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    
    final userId = user.id;
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
        
    if (response == null) {
      // Self-heal: Create profile if missing
      // We try to use metadata from auth if available
      final meta = user.userMetadata;
      final newProfile = {
        'id': userId,
        'full_name': meta?['full_name'] ?? 'Parent',
        'is_parent': true, // Assume auth users are parents intially
        'balance': 0,
        'username': meta?['email']?.split('@')[0] ?? 'parent',
      };
      
      await _supabase.from('profiles').insert(newProfile);
      return newProfile;
    }
    
    return response;
  }

  // Create a "Virtual Kid" profile linked to the current parent
  Future<void> createVirtualKid({
    required String name, 
    required String username, 
    required String pin
  }) async {
     // TEST MODE: Mock Creation
     if (dotenv.env['TEST_MODE'] == 'true') {
       final prefs = await SharedPreferences.getInstance();
       if (prefs.getBool('is_test_parent_logged_in') == true) {
         final kidsJson = prefs.getStringList('test_kids') ?? [];
         final newKid = {
           'id': const Uuid().v4(),
           'full_name': name,
           'username': username.toLowerCase(),
           'pin': pin,
           'is_parent': false,
           'parent_id': '00000000-0000-0000-0000-000000000000',
           'balance': 0,
           'avatar_url': 'https://api.dicebear.com/7.x/avataaars/png?seed=$username&mouth=smile,twinkle&eyes=happy,wink&eyebrows=default,raisedExcited',
           'updated_at': DateTime.now().toIso8601String(),
         };
         kidsJson.add(jsonEncode(newKid));
         await prefs.setStringList('test_kids', kidsJson);
         return;
       }
     }

     final parentId = _supabase.auth.currentUser!.id;
     
     // Generate a random UUID for the kid
     // Note: In a real app we'd use the uuid package, but for simplicity here we can rely on Postgres to generate it 
     // if we just omit the ID? No, our schema might expect it if not auto-gen.
     // Schema says: "id uuid references auth.users not null primary key"
     // We dropped the FK constraint. But it is still a PK.
     // Let's defer ID generation to the database if possible? 
     // The schema: "id uuid references auth.users not null primary key" -> NO DEFAULT on ID.
     // So we MUST provide it.
     
     // Hacky UUID v4 generator for Dart without package if import fails, but we added uuid package.
     // I need to import it.
     const uuid = Uuid();
     
     await _supabase.from('profiles').insert({
       'id': uuid.v4(),
       'full_name': name,
       'username': username,
       'pin': pin,
       'is_parent': false,
       'parent_id': parentId,
       'balance': 0,
       'avatar_url': 'https://api.dicebear.com/7.x/avataaars/png?seed=$username&mouth=smile,twinkle&eyes=happy,wink&eyebrows=default,raisedExcited', // Auto happy avatar
     });
  }

  // Login for Kid (Virtual Profile)
  Future<Map<String, dynamic>?> loginKid({required String username, required String pin}) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('username', username)
        .eq('pin', pin)
        .maybeSingle();
    return response;
  }

  // Fetch a specific profile by ID (Used for refreshing kid stats)
  Future<Map<String, dynamic>?> getProfile(String id) async {
    return await _supabase
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();
  }

  // Fetch all kids linked to this parent
  Future<List<Map<String, dynamic>>> getKids(String parentId) async {
    // TEST MODE: Mock Get Kids
    if (parentId == '00000000-0000-0000-0000-000000000000') {
       final prefs = await SharedPreferences.getInstance();
       final kidsJson = prefs.getStringList('test_kids') ?? [];
       return kidsJson.map((k) => Map<String, dynamic>.from(jsonDecode(k))).toList();
    }

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('parent_id', parentId)
        .order('updated_at', ascending: true); // Or name
    return List<Map<String, dynamic>>.from(response);
  }
}
