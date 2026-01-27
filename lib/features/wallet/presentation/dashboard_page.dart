import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anjra/core/theme/app_theme.dart';
import 'package:anjra/features/wallet/presentation/widgets/balance_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:anjra/core/providers/user_provider.dart';
import 'package:anjra/features/auth/presentation/add_kid_page.dart';
import 'package:anjra/features/auth/presentation/login_page.dart';
import 'package:anjra/features/scan/presentation/scan_page.dart';
import 'package:anjra/features/wallet/presentation/receive_page.dart';
import 'package:anjra/features/wallet/presentation/widgets/transaction_list.dart';
import 'package:anjra/features/auth/repository/profile_repository.dart';
import 'package:anjra/features/wallet/repository/transaction_repository.dart';
import 'package:anjra/features/wallet/presentation/kid_detail_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.savings_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Anjra',
              style: GoogleFonts.outfit(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Only Parents can use the Debug Add Money button
          if (ref.watch(userProvider).asData?.value?.isParent == true)
            IconButton(
              onPressed: () async {
                 // DEBUG: Add Money
                 final user = ref.read(userProvider).asData?.value;
                 if (user != null) {
                   await ref.read(transactionRepositoryProvider).addFunds(user.id, 1000);
                   ref.read(userProvider.notifier).refreshProfile();
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added ₹1000 (Debug)')));
                 }
              }, 
              icon: const Icon(Icons.add_card, color: Colors.green),
              tooltip: 'Debug: Add ₹1000',
            ),
          IconButton(
            onPressed: () {
               ref.read(userProvider.notifier).logout();
               Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
            }, // Logout Logic
            icon: const Icon(Icons.logout_rounded, color: Colors.grey),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(userProvider.notifier).refreshProfile();
          // Also refresh history
          // Since history is autoDispose and watches userProvider, it might refresh automatically if user changes?
          // No, user object might not change deep equality if balance is same? 
          // AsyncNotifier refreshProfile creates NEW AppUser. So yes.
          // Explicitly:
          // Explicitly:
          ref.invalidate(transactionHistoryProvider);
        },
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error loading profile: $err')),
          data: (user) {
            if (user == null) return const Center(child: Text('Session Expired'));
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(), // Required for RefreshIndicator
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BalanceCard(balance: user.balance, username: user.name),
                  const SizedBox(height: 32),
                  // My Family Section (For Parents Only)
                  if (user.isParent) ...[
                    Text(
                      'My Family',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFamilyList(ref, user.id),
                    const SizedBox(height: 32),
                  ],

                  Text(
                    'Quick Actions',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Scan to Pay',
                          color: AppTheme.secondaryColor,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanPage()));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.qr_code_rounded,
                          label: 'My ID',
                          color: AppTheme.accentColor,
                          onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceivePage()));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TransactionList(),
                ],
              ),
            );
          } // End data
        ),
      ),
      floatingActionButton: ref.watch(userProvider).asData?.value?.isParent == true 
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddKidPage())),
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  Widget _buildFamilyList(WidgetRef ref, String parentId) {
    // We use a FutureBuilder here for simplicity, or we could create a new provider.
    // Given the request complexity, a FutureBuilder calling the repo directly (or via a helper) is fine.
    
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(profileRepositoryProvider).getKids(parentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final kids = snapshot.data ?? [];
        if (kids.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text('No kids added yet.')),
          );
        }

        return SizedBox(
          height: 130, // Increased height to prevent overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: kids.length,
            itemBuilder: (context, index) {
              final kid = kids[index];
              // Force "Happy" Avatar for Kids (Override saved URL if needed or just generate fresh)
              // We use DiceBear Avataaars with happy traits
              final happyAvatarUrl = 'https://api.dicebear.com/7.x/avataaars/png?seed=${kid['username']}&mouth=smile,twinkle&eyes=happy,wink&eyebrows=default,raisedExcited';
              
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => KidDetailPage(kidProfile: kid)));
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.shade100,
                          backgroundImage: NetworkImage(happyAvatarUrl), // Force happy
                          // child: kid['avatar_url'] == null ? const Icon(Icons.person) : null, // Removed fallback as we always construct URL
                        ),
                        const SizedBox(height: 8),
                        Text(
                          kid['full_name'] ?? 'Kid', 
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${(kid['balance'] ?? 0).toString()}',
                          style: const TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded, size: 40, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet!',
            style: GoogleFonts.outfit(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
