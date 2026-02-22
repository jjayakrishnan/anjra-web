import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/user_provider.dart';
import '../../admin/presentation/admin_dashboard_page.dart';
import '../../../../core/theme/app_theme.dart';
import 'payment_page.dart';
import '../../scan/presentation/scan_page.dart';
import 'receive_page.dart';
import '../../auth/presentation/add_kid_page.dart';
import 'widgets/transaction_list.dart';
import 'send_money_page.dart';

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
                               child: Column(
                                 children: [
                                   ElevatedButton.icon(
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
                                   const SizedBox(height: 8),
                                   ElevatedButton.icon(
                                     onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddKidPage()));
                                     },
                                     icon: const Icon(Icons.child_care),
                                     label: const Text("Add Kid"),
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: Colors.white,
                                       foregroundColor: AppTheme.primaryColor,
                                     ),
                                   ),
                                 ],
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
                             showModalBottomSheet(
                               context: context,
                               builder: (context) => SafeArea(
                                 child: Column(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     ListTile(
                                       leading: const Icon(Icons.qr_code_scanner),
                                       title: const Text('Scan QR Code'),
                                       onTap: () {
                                         Navigator.pop(context);
                                         Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanPage()));
                                       },
                                     ),
                                     ListTile(
                                       leading: const Icon(Icons.person_search),
                                       title: const Text('Send to Username'),
                                       onTap: () {
                                         Navigator.pop(context);
                                         Navigator.push(context, MaterialPageRoute(builder: (_) => const SendMoneyPage()));
                                       },
                                     ),
                                   ],
                                 ),
                               ),
                             );
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
                   const SizedBox(height: 8),
                   TransactionList(userId: user.id),
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
