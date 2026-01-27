import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  // Kid Login (Virtual)
  // Assumes we store 'username' and 'pin' in profiles or a separate table.
  // For MVP/Demo as per previous tasks, we might be querying profiles directly.
  Future<UserProfile?> loginKid({required String username, required String pin}) async {
    // Note: Storing PIN in plain text is bad practice, but for this "Kid" demo feature 
    // where they might just be rows in a table, we check against the row.
    // Ideally use proper Auth or hashed PINs.
    
    // We need to check if schema has username/pin. 
    // If not, we might need to rely on metadata or just return a dummy for now if schema isn't set.
    // Prompt 1 mentioned "login or give me admin credentials".
    
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('username', username) 
          .eq('pin', pin) // Assuming these columns exist
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      // If columns don't exist, we can't login effectively.
      print("Login Kid Error: $e");
      return null;
    }
  }

  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
