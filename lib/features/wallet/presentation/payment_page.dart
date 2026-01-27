import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anjra/core/theme/app_theme.dart';
import 'package:anjra/features/wallet/repository/transaction_repository.dart';
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
          pin: sender.pin, // Assuming AppUser has this getter now
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
                  Text('Paying User ID:', style: TextStyle(color: Colors.grey[600])),
                  Text(widget.receiverId, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
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
