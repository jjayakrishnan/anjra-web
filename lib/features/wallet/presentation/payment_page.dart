import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anjra/core/theme/app_theme.dart';
import 'package:anjra/features/wallet/repository/transaction_repository.dart';
import 'package:anjra/features/auth/repository/profile_repository.dart'; // import profile repo
import 'package:anjra/core/providers/user_provider.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final String receiverId;
  const PaymentPage({super.key, required this.receiverId});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pay() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid amount')));
       return;
    }

    setState(() => _isLoading = true);
    try {
      final sender = ref.read(userProvider).asData?.value; // AsyncValue safe access
      if (sender == null) throw Exception('Not logged in');

      if (sender.isKid) {
        // Use Kid RPC
        await ref.read(transactionRepositoryProvider).transferFundsKid(
          senderId: sender.id,
          receiverId: widget.receiverId,
          amount: amount,
          pin: sender.pin ?? '0000', // Default if missing
          note: _noteController.text,
        );
      } else {
        // Use Parent RPC
        await ref.read(transactionRepositoryProvider).transferFunds(
          senderId: sender.id,
          receiverId: widget.receiverId,
          amount: amount,
          note: _noteController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));
        Navigator.of(context).popUntil((route) => route.isFirst); // Go back to Dashboard safely
      }
      
      // Refresh balance
      await ref.read(userProvider.notifier).refreshProfile();
      
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Send Money')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('Paying User:', style: TextStyle(color: Colors.grey[600])),
                  FutureBuilder(
                    future: ref.read(profileRepositoryProvider).getProfile(widget.receiverId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
                      }
                      final name = snapshot.data?.fullName ?? snapshot.data?.id ?? widget.receiverId;
                      // Mask ID if falling back, or show name.
                      // If name is null, we might want to mask ID partially? 
                      // For now, let's just show what we have.
                      return Text(
                        name, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), 
                        overflow: TextOverflow.ellipsis
                      );
                    },
                  ),
                  if (true) // Keeping ID small below if needed, or remove. Let's show ID small.
                     Text(widget.receiverId, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                prefixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _pay,
                child: _isLoading ? const CircularProgressIndicator() : const Text('PAY NOW'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
