import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anjra/core/theme/app_theme.dart';
import 'package:anjra/features/auth/repository/auth_repository.dart';
import 'package:anjra/features/wallet/presentation/dashboard_page.dart';

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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
