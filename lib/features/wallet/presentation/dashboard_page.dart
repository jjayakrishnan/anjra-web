import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/user_provider.dart';
import '../../admin/presentation/admin_dashboard_page.dart';
import '../../../../core/theme/app_theme.dart';
import 'payment_page.dart'; // Ensure these exist and are non-empty
import 'receive_page.dart';
// import 'widgets/transaction_list.dart'; // Assume exists or comment out if risky

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Anjra Wallet"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(userProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          )
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("Not logged in"));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.read(userProvider.notifier).refreshProfile(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // Balance Card
                   Card(
                     color: AppTheme.primaryColor,
                     child: Padding(
                       padding: const EdgeInsets.all(24.0),
                       child: Column(
                         children: [
                           Text(
                             "Available Balance",
                             style: TextStyle(color: Colors.white.withOpacity(0.8)),
                           ),
                           const SizedBox(height: 8),
                           Text(
                             "\$${user.balance.toStringAsFixed(2)}",
                             style: const TextStyle(
                               fontSize: 32, 
                               fontWeight: FontWeight.bold,
                               color: Colors.white,
                             ),
                           ),
                           if (user.isParent)
                             Padding(
                               padding: const EdgeInsets.only(top: 16.0),
                               child: ElevatedButton.icon(
                                 onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
                                 },
                                 icon: const Icon(Icons.shield),
                                 label: const Text("Admin Panel"),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.white,
                                   foregroundColor: AppTheme.primaryColor,
                                 ),
                               ),
                             )
                         ],
                       ),
                     ),
                   ),
                   const SizedBox(height: 24),
                   
                   // Action Buttons
                   Row(
                     children: [
                       Expanded(
                         child: ElevatedButton.icon(
                           onPressed: () {
                             // Navigate to Scan or Pay
                             // For now, let's just go to a Payment Page dummy or similar
                             // Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanPage()));
                           },
                           icon: const Icon(Icons.send),
                           label: const Text("Send"),
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: ElevatedButton.icon(
                           onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => ReceivePage(userId: user.id)));
                           },
                           icon: const Icon(Icons.qr_code),
                           label: const Text("Receive"),
                         ),
                       ),
                     ],
                   ),
                   
                   const SizedBox(height: 24),
                   const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   const Center(child: Text("No transactions yet.")),
                   // TransactionList() // Add back if file exists
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
