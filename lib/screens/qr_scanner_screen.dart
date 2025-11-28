import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'menu_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final Map<String, List<String>> clientHistory;

  const QRScannerScreen({
    super.key,
    required this.clientHistory,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isFlashOn = false;
  bool _isCameraFront = false;
  bool _navigationDone = false;

  /// ---------------------------
  /// SAFE NAVIGATION FUNCTION
  /// ---------------------------
  void _goToMenu(String tableId, String clientId) {
    if (_navigationDone) return;
    _navigationDone = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MenuScreen(
          clientId: clientId,
          tableId: tableId,
          clientHistory: widget.clientHistory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() {
                _isFlashOn = !_isFlashOn;
              });
              cameraController.toggleTorch();
            },
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(_isCameraFront ? Icons.camera_front : Icons.camera_rear),
            onPressed: () {
              setState(() {
                _isCameraFront = !_isCameraFront;
              });
              cameraController.switchCamera();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                if (_navigationDone) return;

                final barcode = capture.barcodes.first;
                final code = barcode.rawValue;

                if (code == null) return;

                final parts = code.split(';');
                final tableId = parts.isNotEmpty ? parts[0] : "T1";
                final clientId = parts.length > 1
                    ? parts[1]
                    : "CLIENT_${DateTime.now().millisecondsSinceEpoch}";

                _goToMenu(tableId, clientId);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Scannez le QR code de votre table',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
