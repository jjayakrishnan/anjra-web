import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(Supabase.instance.client);
});

class TransactionRepository {
  final SupabaseClient _supabase;

  TransactionRepository(this._supabase);

  Future<void> transferFunds({
    required String senderId,
    required String receiverId,
    required double amount,
    String? note,
  }) async {
    await _supabase.rpc('transfer_funds', params: {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'amount': amount,
      'note': note,
    });
  }

  Future<void> transferFundsKid({
    required String senderId,
    required String receiverId,
    required double amount,
    required String pin,
    String? note,
  }) async {
    await _supabase.rpc('transfer_funds_kid', params: {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'amount': amount,
      'pin': pin,
      'note': note,
    });
  }

  Stream<List<Map<String, dynamic>>> getTransactionHistory(String userId) {
    return _supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('sender_id', userId) // This only gets sent transactions?
        // real-time filters are limited. 
        // Better to use .order() and limit?
        // Supabase stream supports basic filters.
        // OR logic in stream is tricky.
        // Let's settle for just "Recent Transactions" via standard query for MVP, or stream if simple.
        // Let's simple query for now to ensure reliability.
        .order('created_at')
        .limit(20);
  }
  
  Future<List<Map<String, dynamic>>> fetchHistory(String userId) async {
    // Check for TEST_MODE
    if (dotenv.env['TEST_MODE'] == 'true') {
      // Return mock transactions
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
      return [
        {
          'id': 'tx-1',
          'amount': 50.0,
          'created_at': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
          'note': 'Weekly Allowance',
          'sender_id': 'test-parent-id',
          'receiver_id': userId,
          'sender': {'full_name': 'Parent', 'username': 'parent'},
          'receiver': {'full_name': 'Kid', 'username': 'kid'},
        },
        {
          'id': 'tx-2',
          'amount': 10.0,
          'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'note': 'Ice Cream',
          'sender_id': userId,
          'receiver_id': 'shop-id',
          'sender': {'full_name': 'Kid', 'username': 'kid'},
          'receiver': {'full_name': 'Ice Cream Shop', 'username': 'shop'},
        },
      ];
    }

    // Basic history fetch. 
    // NOTE: This will fail for Kids due to RLS if they are not auth.uid()
    // For Kids, we must use the RPC if we have the PIN? But here we don't passed PIN.
    // Instead, callers should use fetchKidHistory if they know it's a kid.
    
    final response = await _supabase
        .from('transactions')
        .select('*, sender:sender_id(username, full_name), receiver:receiver_id(username, full_name)')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false)
        .limit(20);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchKidHistory(String userId, String pin) async {
    // Check for TEST_MODE
    if (dotenv.env['TEST_MODE'] == 'true') {
      // Return mock transactions (reuse logic or vary slightly)
      await Future.delayed(const Duration(milliseconds: 500));
      return [
         {
          'id': 'tx-kid-1',
          'amount': 25.0,
          'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'note': 'Chore Reward',
          'sender_id': 'test-parent-id',
          'receiver_id': userId,
          'sender': {'full_name': 'Parent', 'username': 'parent'},
          'receiver': {'full_name': 'Me', 'username': 'kid'},
        },
      ];
    }

    final response = await _supabase.rpc('get_kid_transactions', params: {
      'kid_id': userId,
      'pin': pin,
    });
    // The RPC returns flattened structure with sender_name, receiver_name.
    // We need to map it to match the structure expected by UI (which expects nested sender/receiver objects or handle flat)
    // UI expects: tx['sender']['username'] etc.
    // Let's adapt the response here.
    return List<Map<String, dynamic>>.from(response).map((row) {
       // Reconstruct sender/receiver objects for UI compatibility
       return {
         ...row,
         'sender': {'full_name': row['sender_name'], 'username': null}, 
         'receiver': {'full_name': row['receiver_name'], 'username': null},
       };
    }).toList();
  }
  Future<void> addFunds(String userId, double amount) async {
    await _supabase.rpc('add_funds', params: {
      'user_id': userId,
      'amount': amount,
    });
  }
}
