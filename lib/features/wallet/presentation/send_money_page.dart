import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/models/user_profile.dart';
import '../repository/transaction_repository.dart';

class SendMoneyPage extends ConsumerStatefulWidget {
  const SendMoneyPage({super.key});

  @override
  ConsumerState<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends ConsumerState<SendMoneyPage> {
  TextEditingController? _autoCompleteController;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  bool _isFetchingUsers = true;
  
  List<UserProfile> _familyMembers = [];
  UserProfile? _selectedUser;

  @override
  void initState() {
    super.initState();
    _fetchFamilyMembers();
  }

  Future<void> _fetchFamilyMembers() async {
    try {
      final currentUser = ref.read(userProvider).value;
      if (currentUser == null) return;

      final List<dynamic> response;
      if (currentUser.isParent) {
        if (currentUser.id == '00000000-0000-0000-0000-000000000000') {
           // Demo reviewer account: fetch some kids to allow testing the Send flow
           response = await Supabase.instance.client
               .from('profiles')
               .select()
               .eq('is_parent', false)
               .limit(10);
        } else {
           // Fetch all kids belonging to this parent
           response = await Supabase.instance.client
               .from('profiles')
               .select()
               .eq('parent_id', currentUser.id);
        }
      } else {
        // Find parent and siblings
        // If kid, we need to know their parent id, assuming it's parent_id
        final kidData = await Supabase.instance.client
            .from('profiles')
            .select('parent_id')
            .eq('id', currentUser.id)
            .single();
        final parentId = kidData['parent_id'];
        
        response = await Supabase.instance.client
            .from('profiles')
            .select()
            .or('id.eq.$parentId,parent_id.eq.$parentId');
      }

      final allProfiles = response.map((data) => UserProfile.fromJson(data)).toList();
      
      if (mounted) {
        setState(() {
          // Remove self from the list
          _familyMembers = allProfiles.where((p) => p.id != currentUser.id).toList();
          _isFetchingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingUsers = false);
      print("Error fetching family members: $e");
    }
  }

  Future<void> _submitTransfer() async {
    final usernameText = _autoCompleteController?.text.trim() ?? '';
    final amountText = _amountController.text.trim();
    final note = _noteController.text.trim();

    FocusScope.of(context).unfocus();

    if (usernameText.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a username and amount.')));
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount greater than 0.')));
      return;
    }

    // Try to find a family member whose name OR id matches exactly or partially (case-insensitive)
    UserProfile? matchedUser = _selectedUser;

    if (matchedUser == null || (matchedUser.fullName ?? matchedUser.id).toLowerCase() != usernameText.toLowerCase()) {
      matchedUser = _familyMembers.where((p) {
        final textLower = usernameText.toLowerCase();
        final nameLower = p.fullName?.toLowerCase() ?? '';
        return nameLower == textLower || 
               p.id.toLowerCase() == textLower ||
               nameLower.contains(textLower) ||
               textLower.contains(nameLower);
      }).firstOrNull;
    }

    if (matchedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not find a family member named '$usernameText'.")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(userProvider).value;
      if (currentUser == null) throw Exception("Not logged in");
      if (currentUser.balance < amount) throw Exception("Insufficient funds");

      final repo = ref.read(transactionRepositoryProvider);
      await repo.transferFunds(
        senderId: currentUser.id,
        receiverId: matchedUser.id,
        amount: amount,
        note: note.isNotEmpty ? note : 'Sent by Username',
      );

      await ref.read(userProvider.notifier).refreshProfile();

      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully sent \$${amount.toStringAsFixed(2)} to ${matchedUser.fullName ?? matchedUser.id}!')));
         Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Transfer Failed'),
            content: Text(e.toString()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: _isFetchingUsers 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select a family member to send money to.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Autocomplete<UserProfile>(
              displayStringForOption: (UserProfile option) => option.fullName ?? option.id,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<UserProfile>.empty();
                }
                final lower = textEditingValue.text.toLowerCase();
                return _familyMembers.where((UserProfile option) {
                  return (option.fullName?.toLowerCase().contains(lower) ?? false) ||
                         (option.id.toLowerCase().contains(lower));
                });
              },
              onSelected: (UserProfile selection) {
                _selectedUser = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                _autoCompleteController = controller;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  decoration: const InputDecoration(
                    labelText: 'Username (Exactly as registered)',
                    prefixIcon: Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (\$)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitTransfer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Text('Send Money', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
