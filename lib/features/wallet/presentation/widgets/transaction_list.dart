import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anjra/features/wallet/repository/transaction_repository.dart';
import '../../../../core/models/transaction.dart';
import 'package:intl/intl.dart';

class TransactionList extends ConsumerWidget {
  final String userId;
  const TransactionList({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<dynamic>>(
      future: ref.read(transactionRepositoryProvider).fetchTransactions(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        
        final transactionsRaw = snapshot.data ?? [];
        if (transactionsRaw.isEmpty) {
          return const Center(child: Text("No transactions yet."));
        }

        // Ideally parse to Transaction model safely
        final transactions = transactionsRaw.map((e) {
             try {
               return Transaction.fromJson(Map<String, dynamic>.from(e));
             } catch (err) {
               print('Failed to parse transaction: $err');
               print('Raw transaction data: $e');
               return null;
             }
        }).whereType<Transaction>().toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            final isCredit = tx.receiverId == userId;
            final hasNote = tx.note != null && tx.note!.isNotEmpty;
            final displayTitle = hasNote ? tx.note! : (isCredit ? "Received from ${tx.senderId}" : "Sent to ${tx.receiverId}");
            final displaySubtitle = hasNote 
                ? "${isCredit ? 'From: ' + tx.senderId : 'To: ' + tx.receiverId} • ${DateFormat.yMMMd().format(tx.createdAt)}"
                : DateFormat.yMMMd().format(tx.createdAt);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade100)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  child: Icon(
                    isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  displayTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(displaySubtitle),
                trailing: Text(
                  "${isCredit ? '+' : '-'} \$${tx.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: isCredit ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
