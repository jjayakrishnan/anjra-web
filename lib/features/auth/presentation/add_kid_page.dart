import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anjra/core/theme/app_theme.dart';
import 'package:anjra/features/auth/repository/profile_repository.dart';

class AddKidPage extends ConsumerStatefulWidget {
  const AddKidPage({super.key});

  @override
  ConsumerState<AddKidPage> createState() => _AddKidPageState();
}

class _AddKidPageState extends ConsumerState<AddKidPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(profileRepositoryProvider).createVirtualKid(
            name: _nameController.text.trim(),
            username: _usernameController.text.trim(),
            pin: _pinController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kid Added Successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Add New Kid')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username (for login)', prefixIcon: Icon(Icons.alternate_email)),
                validator: (v) => v!.length < 3 ? 'Min 3 chars' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'Secret PIN (4 digits)', prefixIcon: Icon(Icons.lock_outline)),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (v) => v!.length != 4 ? 'Must be 4 digits' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Create Kid Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
