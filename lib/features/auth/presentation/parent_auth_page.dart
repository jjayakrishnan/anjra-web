import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:anjra/core/theme/app_theme.dart';
import 'package:anjra/features/auth/repository/auth_repository.dart';
import 'package:anjra/features/admin/presentation/admin_dashboard_page.dart';
// Note: You might need to adjust the import if UserProvider is used for state
import 'package:anjra/features/admin/presentation/admin_dashboard_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:anjra/core/providers/user_provider.dart';
import 'package:anjra/core/models/user_profile.dart';

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

    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (email.isEmpty || password.length < 6) {
      _showErrorDialog('Invalid Input', 'Please enter a valid email and a password with at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      
      if (_isSignUp) {
        await repo.signUpParent(email: email, password: password, fullName: "Parent User");
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sign Up Successful'),
              content: const Text('Your account has been created! Please sign in with your new credentials.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() => _isSignUp = false);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        await repo.signInParent(email: email, password: password);
        if (mounted) {
           await ref.read(userProvider.notifier).refreshProfile();
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome back!')));
             Navigator.of(context).pushReplacementNamed('/dashboard');
           }
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        if (e.message.contains('Email not confirmed')) {
          _showErrorDialog('Email Not Confirmed', 'Please check your email and click the confirmation link to activate your account. If you just created the account, you may need to ask the app owner to disable email confirmation in the database.');
        } else if (e.message.contains('Invalid login credentials')) {
          _showErrorDialog('Login Failed', 'The email or password you entered is incorrect. Please try again.');
        } else {
          _showErrorDialog('Authentication Failed', e.message);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Authentication Failed', 'An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an email address')));
                return;
              }
              Navigator.of(context).pop();
              setState(() => _isLoading = true);
              try {
                await ref.read(authRepositoryProvider).resetPassword(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset link sent.')));
                }
              } catch (e) {
                if (mounted) {
                  _showErrorDialog('Reset failed', 'Could not send reset link.');
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
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
            if (!_isSignUp)
              TextButton(
                onPressed: () => _showForgotPasswordDialog(),
                child: const Text('Forgot Password?'),
              ),
            TextButton(
              onPressed: () => setState(() => _isSignUp = !_isSignUp),
              child: Text(_isSignUp ? 'Already have an account? Login' : 'New here? Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
