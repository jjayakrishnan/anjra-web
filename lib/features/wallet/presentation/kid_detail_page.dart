import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:anjra/core/providers/user_provider.dart';
import 'package:anjra/core/theme/app_theme.dart';
import 'package:anjra/features/wallet/presentation/payment_page.dart';
import 'package:anjra/features/wallet/presentation/widgets/balance_card.dart';
import 'package:anjra/features/wallet/presentation/widgets/transaction_list.dart';

class KidDetailPage extends ConsumerWidget {
  final Map<String, dynamic> kidProfile;

  const KidDetailPage({super.key, required this.kidProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = (kidProfile['balance'] as num?)?.toDouble() ?? 0.0;
    final name = kidProfile['full_name'] ?? 'Kid';
    final userId = kidProfile['id'];
    
    final isParent = ref.watch(userProvider).asData?.value?.isParent ?? false;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.transparent,
        elevation: 0,
       ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                     radius: 50,
                     backgroundImage: NetworkImage(kidProfile['avatar_url'] ?? ''),
                     child: kidProfile['avatar_url'] == null ? const Icon(Icons.person, size: 50) : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name, 
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                   Text(
                    '@${kidProfile['username']}', 
                    style: GoogleFonts.outfit(color: Colors.grey)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            BalanceCard(balance: balance, username: name),
            const SizedBox(height: 24),
            
            // Allow Parent to Send Money
            if (isParent)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentPage(receiverId: userId)));
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Send Allowance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

            const SizedBox(height: 32),
             Text(
                'History',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
            // Pass the kid's ID to fetch THEIR history
            TransactionList(userId: userId),
          ],
        ),
      ),
    );
  }
}
