import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/supabase_constants.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/wallet/presentation/dashboard_page.dart';
import 'features/admin/presentation/admin_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load Env
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.publishableKey,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anjra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Simple routing
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/admin': (context) => const AdminDashboardPage(),
      },
      // home: const LoginPage(), // Handled by initialRoute
    );
  }
}
