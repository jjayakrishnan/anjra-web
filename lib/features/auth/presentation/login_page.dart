import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anjra/core/theme/app_theme.dart';
import 'package:anjra/features/auth/presentation/parent_auth_page.dart';
import 'package:anjra/features/auth/presentation/kid_auth_page.dart';
import 'package:anjra/core/providers/user_provider.dart';
import 'package:anjra/core/models/user_profile.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool isKidMode = true; // Default to kid mode as it's the main user base

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Title
                Image.asset(
                  'assets/store/app_logo.png',
                  height: 120,
                ),
                const SizedBox(height: 16),
                Text(
                  'Anjra',
                  style: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  'Your Pocket Money Power!',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // Toggle Switch
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton(
                        title: "I'm a Kid",
                        isActive: isKidMode,
                        onTap: () => setState(() => isKidMode = true),
                      ),
                      _buildToggleButton(
                        title: "I'm a Parent",
                        isActive: !isKidMode,
                        onTap: () => setState(() => isKidMode = false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Content Area card
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isKidMode ? const KidAuthPage() : const ParentAuthPage(),
                ),
                const SizedBox(height: 24),
                
                // App Store Demonstration Mode
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final reviewerProfile = UserProfile(
                        id: 'demo_user_id',
                        email: 'demo@anjra.app',
                        fullName: 'App Demonstrator',
                        isParent: true,
                        balance: 5000.0,
                      );
                      await ref.read(userProvider.notifier).setMockUser(reviewerProfile);
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/dashboard');
                      }
                    },
                    icon: const Icon(Icons.explore),
                    label: const Text('App Store Demo / Review Mode'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.secondaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}
