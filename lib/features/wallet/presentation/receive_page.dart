import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:anjra/core/providers/user_provider.dart';
import 'package:anjra/core/theme/app_theme.dart';

class ReceivePage extends ConsumerWidget {
  final String userId;
  const ReceivePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We already have userId, but can watch user for name/username update if needed.
    // However, if passed implicitly, we can just use the ID for QR.
    
    // The data encoded in QR. 
    // Format: "anjra:USER_ID" to be safe and specific.
    final qrData = "anjra:$userId";
    
    // Attempt to get user details for display, but safe to fail
    final user = ref.watch(userProvider).asData?.value;
    final displayName = user?.fullName ?? "User"; // Fallback name

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('My QR Code', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 250.0,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppTheme.primaryColor,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan to pay me',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Show this to your friend!',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
