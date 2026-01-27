import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anjra/core/theme/app_theme.dart';
import 'package:anjra/features/auth/repository/profile_repository.dart';
import 'package:anjra/core/providers/user_provider.dart';
import 'package:anjra/features/wallet/presentation/dashboard_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KidAuthPage extends ConsumerStatefulWidget {
  const KidAuthPage({super.key});

  @override
  ConsumerState<KidAuthPage> createState() => _KidAuthPageState();
}

class _KidAuthPageState extends ConsumerState<KidAuthPage> {
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final pin = _pinController.text.trim();

    if (username.isEmpty || pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Details')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final kidProfile = await repo.loginKid(username: username, pin: pin);
      
      if (kidProfile != null) {
        // Success! Set global user state
        // Commented out to fix "Session Expired" issue. 
        // Force sign out breaks the flow if Kid login is virtual-only and we rely on memory.
        // await Supabase.instance.client.auth.signOut();
        
        ref.read(userProvider.notifier).setKidUser(kidProfile);
        
        if (mounted) {
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        }
      } else {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong username or PIN')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Enter Your Secret ID',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_pin),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: '4-Digit PIN',
                prefixIcon: Icon(Icons.lock),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Enter Anjra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
