import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:anjra/core/theme/app_theme.dart';
import 'package:anjra/features/auth/repository/auth_repository.dart';
import 'package:anjra/features/admin/presentation/admin_dashboard_page.dart';
// Note: You might need to adjust the import if UserProvider is used for state
// import 'package:anjra/core/providers/user_provider.dart'; 

class ParentAuthPage extends ConsumerStatefulWidget {
  const ParentAuthPage({super.key});

  @override
  ConsumerState<ParentAuthPage> createState() => _ParentAuthPageState();
}

class _ParentAuthPageState extends ConsumerState<ParentAuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Email or Password (min 6 chars)')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      
      if (_isSignUp) {
        await repo.signUpParent(email: email, password: password, fullName: "Parent User"); // Add name field if needed
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign Up Successful! Please Sign In.')));
        setState(() => _isSignUp = false);
      } else {
        await repo.signInParent(email: email, password: password);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome back!')));
           // Navigate to Admin Dashboard directly for this task request
           // OR standard dashboard. For now, I'll push to Admin Dashboard if it's the "admin" user requested.
           
           // For now, let's just stay here or go to main dashboard?
           // The user specifically asked for High Level User.
           // I will add a button below to go to Admin Dashboard manually.
        }
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
            Text(
              _isSignUp ? 'Create Parent Account' : 'Parent Login',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : Text(_isSignUp ? 'Sign Up' : 'Login'),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isSignUp = !_isSignUp),
              child: Text(_isSignUp ? 'Already have an account? Login' : 'New here? Create Account'),
            ),
            const Divider(),
            // Backdoor / Admin Access
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                );
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text("ADMIN DASHBOARD (DEBUG)"),
            ),
          ],
        ),
      ),
    );
  }
}
