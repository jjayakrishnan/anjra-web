import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:anjra/core/theme/app_theme.dart';
import 'package:anjra/features/wallet/presentation/payment_page.dart'; // Will create next

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final String code = barcode.rawValue!;
        // Expected format: "anjra:USER_ID" or just "USER_ID"
        // Let's assume the QR contains the UUID of the receiver.
        _handleCode(code);
        break; 
      }
    }
  }

  Future<void> _handleCode(String code) async {
    setState(() => _isProcessing = true);
    
    // Basic validation or parsing
    String receiverId = code;
    if (code.startsWith('anjra:')) {
      receiverId = code.split(':')[1];
    }

    if (mounted) {
      // Pause scanner? MobileScannerController helps but navigating away naturally pauses.
      await Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => PaymentPage(receiverId: receiverId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR to Pay'), backgroundColor: Colors.transparent),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.secondaryColor, width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: const Text(
              'Point camera at a friend\'s QR code',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, shadows: [Shadow(blurRadius: 10, color: Colors.black)]),
            ),
          )
        ],
      ),
    );
  }
}
