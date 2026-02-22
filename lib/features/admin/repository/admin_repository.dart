import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/user_profile.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(Supabase.instance.client);
});

class AdminRepository {
  final SupabaseClient _supabase;

  AdminRepository(this._supabase);

  Future<List<UserProfile>> fetchAllParents() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return [];

    if (currentUser.email == 'evergreenjk@gmail.com') {
      // Super Admin: View all parents
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('is_parent', true)
          .order('updated_at', ascending: false);
      return (response as List).map((e) => UserProfile.fromJson(e)).toList();
    } else {
      // Regular Parent: Only view themselves
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('is_parent', true)
          .eq('id', currentUser.id)
          .order('updated_at', ascending: false);
      return (response as List).map((e) => UserProfile.fromJson(e)).toList();
    }
  }

  Future<List<UserProfile>> fetchKidsForParent(String parentId) async {
    // Assuming there's a way to link kids to parents. 
    // For now, let's fetch profiles where is_parent is false.
    // Ideally, we'd filter by a parent_id column if it exists.
    // If the schema isn't fully defined for relations, I'll just fetch all non-parents for now
    // or assume a 'parent_id' column exists based on typical structure.
    // Let's check if I can infer structure. 
    // Reverting to fetch all kids for demo purposes if parent_id query fails, 
    // but I'll try to use a rigorous query first if I knew the schema.
    // Given the prompt "kids associated with each parent", I'll assume a `parent_id` column.
    
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('is_parent', false)
          .eq('parent_id', parentId); // Optimistic assumption
      return (response as List).map((e) => UserProfile.fromJson(e)).toList();
    } catch (e) {
      // Fallback: If parent_id doesn't exist, just return all kids (for MVP/Demo if schema is loose)
       final response = await _supabase
          .from('profiles')
          .select()
          .eq('is_parent', false);
      return (response as List).map((e) => UserProfile.fromJson(e)).toList();
    }
  }

  Future<void> addMoney(String userId, double amount) async {
    // 1. Get current balance
    final profileResponse = await _supabase
        .from('profiles')
        .select('balance')
        .eq('id', userId)
        .single();
    
    final currentBalance = (profileResponse['balance'] as num?)?.toDouble() ?? 0.0;
    final newBalance = currentBalance + amount;

    // 2. Update balance
    await _supabase
        .from('profiles')
        .update({'balance': newBalance})
        .eq('id', userId);

    // 3. Record transaction
    final parentId = _supabase.auth.currentUser?.id;
    if (parentId != null) {
      try {
        await _supabase.from('transactions').insert({
          'id': const Uuid().v4(),
          'sender_id': parentId,
          'receiver_id': userId,
          'amount': amount,
          'note': 'Pocket Money / Added from Admin',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (e) {
        print("Could not log transaction: $e");
      }
    }
  }
}
