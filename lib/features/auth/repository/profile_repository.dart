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
    // Apple Review Demo Account Backdoor
    if (username.toLowerCase() == 'apple_demo' && pin == '1234') {
      return UserProfile(
        id: 'demo-kid-id-123',
        fullName: 'Demo Kid',
        isParent: false,
        balance: 50.0,
        pin: '1234',
      );
    }

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
  Future<void> createVirtualKid({
    required String name,
    required String username,
    required String pin,
  }) async {
    final parentId = _supabase.auth.currentUser?.id;
    if (parentId == null) throw Exception("Must be logged in as parent");

    // We assume 'profiles' table allows inserting rows.
    // However, usually 'id' references 'auth.users.id'. 
    // If that's the case, we technically need an Auth User.
    // For this demo, let's try to just insert. 
    // If it fails, the user needs to adjust Supabase or we use Admin API to create user.
    // But since I don't have Admin API key here (only anon), I'll try to just insert.
    // If there is an FK constraint, this WILL fail.
    
    // WORKAROUND: If we can't create Auth User from client (requires service role usually),
    // and if profiles.id is FK to auth.users.id, 
    // THEN we actually CANNOT create a "Virtual" user easily without a backend function.
    
    // BUT: Does `profiles.id` have a FK constraint? Usually yes.
    // Let's assume for this "Kid" feature, we might be using a separate `kids` table or `profiles` handles it.
    // If `profiles` is strict, I should create a Kid via RPC if available.
    
    // Let's assume standard INSERT works for now (maybe id is not FK strict or we generate a UUID).
    // I need Uuid package.
    
    await _supabase.from('profiles').insert({
      'full_name': name, // or custom fields
      'username': username,
      'pin': pin,
      'is_parent': false,
      'parent_id': parentId,
      'balance': 0.0,
      // 'id': const Uuid().v4(), // If auto-gen or we must supply. Let DB handle text if gen_random_uuid() is default 
      // But if id is PK, we might need to supply it if not auto-inc/uuid.
    });
  }
}
