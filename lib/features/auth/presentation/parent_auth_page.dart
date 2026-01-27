import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anjra/core/theme/app_theme.dart';
import 'package:anjra/features/auth/repository/auth_repository.dart';
import 'package:anjra/features/wallet/presentation/dashboard_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentAuthPage extends ConsumerStatefulWidget {
  const ParentAuthPage({super.key});

  @override
  ConsumerState<ParentAuthPage> createState() => _ParentAuthPageState();
}

class _ParentAuthPageState extends ConsumerState<ParentAuthPage> {
  bool isSignUp = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    setState(() => _isLoading = true);
    
    print('DEBUG: TEST_MODE=${dotenv.env['TEST_MODE']}');
    print('DEBUG: Email=${_emailController.text}');

    // TEST MODE LOGIC
    // Check Env Var OR Magic Email (fallback)
    final isTestModeEnv = dotenv.env['TEST_MODE'] == 'true';
    final isMagicEmail = _emailController.text.trim() == 'force_test@example.com';
    
    if ((isTestModeEnv || isMagicEmail) && _emailController.text.trim().endsWith('@example.com')) {
       // Simulate success
       print('DEBUG: Test Mode Triggered. Env: $isTestModeEnv, Magic: $isMagicEmail');
       await Future.delayed(const Duration(milliseconds: 500)); // Fake network delay
       final prefs = await SharedPreferences.getInstance();
       await prefs.setBool('is_test_parent_logged_in', true);
       await prefs.setString('test_parent_name', _nameController.text.isNotEmpty ? _nameController.text : 'Test Parent');
       
       if (mounted) {
         Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
       }
       return;
    }

    else {
       // REAL AUTH LOGIC - Only runs if Test Mode is FALSE
       final repo = ref.read(authRepositoryProvider);
       try {
         if (isSignUp) {
           await repo.signUpParent(
             email: _emailController.text.trim(),
             password: _passwordController.text.trim(),
             fullName: _nameController.text.trim(),
           );
           if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign up successful! Please check your email.')));
         } else {
           await repo.signInParent(
             email: _emailController.text.trim(),
             password: _passwordController.text.trim(),
           );
         if (mounted) {
           Navigator.of(context).pushReplacement(
             MaterialPageRoute(builder: (_) => const DashboardPage()),
           );
         }
         }
       } catch (e) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
       }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (dotenv.env['TEST_MODE'] == 'true')
                Container(
                  color: Colors.orange.shade100,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: const Text(
                    'TEST MODE ACTIVE\nLogin with @example.com to bypass auth',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Text(
                  // DEBUG INFO TEXT
                  'DEBUG: EnvTest=${dotenv.env['TEST_MODE']} Magic=${_emailController.text == 'force_test@example.com'}',
                   style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                isSignUp ? 'Create Parent Account' : 'Parent Login',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (isSignUp) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                  validator: (value) => value!.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                validator: (value) => value!.contains('@') ? null : 'Valid email required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Min 6 chars' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isSignUp ? 'Sign Up' : 'Login'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => isSignUp = !isSignUp),
                child: Text(isSignUp ? 'Already have an account? Login' : 'New here? Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
