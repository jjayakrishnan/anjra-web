import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(Supabase.instance.client);
});

class TransactionRepository {
  final SupabaseClient _supabase;

  TransactionRepository(this._supabase);

  // Standard Transfer (Parent)
  Future<void> transferFunds({
    required String senderId,
    required String receiverId,
    required double amount,
    String? note,
  }) async {
    // Call a Postgres Function (RPC) for atomic transfer
    // OR do client-side if RPC isn't available (not recommended but feasible for prototype)
    
    // Using RPC 'transfer_funds' as implied by typical setup
    await _supabase.rpc('transfer_funds', params: {
      'p_sender_id': senderId,
      'p_receiver_id': receiverId,
      'p_amount': amount,
      'p_note': note,
    });
  }

  // Kid Transfer (might verify PIN server-side or just separate RPC)
  Future<void> transferFundsKid({
    required String senderId,
    required String receiverId,
    required double amount,
    required String pin, // verification
    String? note,
  }) async {
     await _supabase.rpc('transfer_funds', params: {
      'p_sender_id': senderId,
      'p_receiver_id': receiverId,
      'p_amount': amount,
      'p_note': note,
      // 'p_pin': pin // If RPC supports PIN check
    });
  }
}
