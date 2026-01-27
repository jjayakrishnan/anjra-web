import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:anjra/features/wallet/repository/transaction_repository.dart';
import 'package:anjra/core/providers/user_provider.dart';

final transactionHistoryProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String?>((ref, userId) async {
  final user = ref.watch(userProvider).asData?.value;
  final targetId = userId ?? user?.id;
  
  if (targetId == null) return [];
  
  // If we are looking at MY history and I am a kid
  if (userId == null && user?.isKid == true) {
     return ref.read(transactionRepositoryProvider).fetchKidHistory(targetId, user!.pin);
  }
  
  return ref.read(transactionRepositoryProvider).fetchHistory(targetId);
});

class TransactionList extends ConsumerWidget {
  final String? userId; // If null, uses current user
  
  const TransactionList({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(transactionHistoryProvider(userId));

    return historyAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
      error: (e, s) => Text('Error: $e'),
      data: (transactions) {
        if (transactions.isEmpty) {
          return Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.history_rounded, size: 40, color: Colors.grey.shade300),
                ),
                const SizedBox(height: 12),
                Text('No transactions yet!', style: GoogleFonts.outfit(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final tx = transactions[index];
            
            // Determine "Who am I" in this context
            final contextUserId = userId ?? ref.read(userProvider).asData?.value?.id;
            
            final isSender = tx['sender_id'] == contextUserId;
            final otherParty = isSender ? tx['receiver'] : tx['sender'];
            // Handle nulls if expansion failed or user deleted (use 'Unknown')
            final otherName = otherParty != null ? (otherParty['username'] ?? otherParty['full_name']) : 'Unknown';
            
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: isSender ? Colors.deepOrange.shade50 : Colors.green.shade50,
                child: Icon(
                  isSender ? Icons.arrow_outward_rounded : Icons.south_west_rounded,
                  color: isSender ? Colors.deepOrange : Colors.green,
                ),
              ),
              title: Text(
                isSender ? 'To $otherName' : 'From $otherName',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                tx['note'] ?? 'No note',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              trailing: Text(
                '${isSender ? "-" : "+"} ₹${tx['amount']}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: isSender ? Colors.red : Colors.green,
                  fontSize: 16,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
