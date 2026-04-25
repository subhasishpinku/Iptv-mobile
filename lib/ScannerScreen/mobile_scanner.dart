import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan QR / Barcode"),
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: [
          // 📷 Camera
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            onDetect: (barcodeCapture) async {
              if (isScanned) return;

              final barcodes = barcodeCapture.barcodes;

              for (final barcode in barcodes) {
                final code = barcode.rawValue;

                if (code != null) {
                  isScanned = true;

                  // 📋 Copy to clipboard
                  await Clipboard.setData(ClipboardData(text: code));

                  final Uri? uri = Uri.tryParse(code);

                  // 🌐 Auto open if link
                  if (uri != null &&
                      (uri.scheme == 'http' || uri.scheme == 'https')) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }

                  // ✅ Only small confirmation (no link show)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Copied & Opened"),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  // 🔙 back
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.pop(context);
                  });

                  break;
                }
              }
            },
          ),

          // 🔲 Overlay + Center Box
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // 🔳 Dark overlay (top)
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
                SizedBox(
                  height: 250,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(color: Colors.black.withOpacity(0.6)),
                      ),
                      const SizedBox(width: 250),
                      Expanded(
                        child: Container(color: Colors.black.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
              ],
            ),
          ),

          // 📌 Instruction Text
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                "Align QR code within the frame",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
