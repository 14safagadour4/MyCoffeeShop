import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'menu_screen.dart';
import '../widgets/animated_mascot.dart';
import 'package:coffee_shop_ai/models/user_model.dart';
import 'account_creation_screen.dart';

class MobileQRScanner extends StatefulWidget {
  final Map<String, List<String>> clientHistory;

  const MobileQRScanner({
    super.key,
    required this.clientHistory,
  });

  @override
  State<MobileQRScanner> createState() => _MobileQRScannerState();
}

class _MobileQRScannerState extends State<MobileQRScanner> {
  bool _isScanning = false;
  bool _isSimulating = false;
  bool _navigationDone = false;
  MyUser? _currentUser;

  /// ---------------------------
  /// SAFE NAVIGATION FUNCTION
  /// ---------------------------
  void _goToMenu(String tableId, String clientId) {
    if (_navigationDone) return; // ⛔ empêche double navigation
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

  /// ---------------------------
  /// SIMULATION (bouton marron)
  /// ---------------------------
  void _simulateScan() {
    if (_isSimulating) return;
    setState(() => _isSimulating = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      _goToMenu("TABLE1", "CLIENT123");
    });
  }

  /// ---------------------------
  /// MODE CAMERA (QR réel)
  /// ---------------------------
  void _startRealScan() {
    setState(() => _isScanning = true);
  }

  /// ---------------------------
  /// CRÉATION COMPTE - CORRIGÉ
  /// ---------------------------
  void _createAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountCreationScreen(),
      ),
    ).then((value) {
      // Cette partie sera exécutée quand AccountCreationScreen sera fermé
      // Vous pouvez ajouter du code ici si nécessaire après la création de compte
      print("Retour de l'écran de création de compte");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/coffee_bg.jpg',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.5)),

          /// ---------------------------
          /// ÉCRAN D'ACCUEIL
          /// ---------------------------
          Center(
            child: !_isScanning
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AnimatedMascot(),
                      const SizedBox(height: 30),
                      const Text(
                        'Bienvenue au Coffee Shop ☕',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Scannez votre QR ou simulez pour continuer',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),

                      /// SIMULER
                      ElevatedButton.icon(
                        onPressed: _simulateScan,
                        icon: const Icon(Icons.coffee),
                        label: const Text("Simuler le Scan"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[400],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      /// SCAN RÉEL
                      OutlinedButton.icon(
                        onPressed: _startRealScan,
                        icon: const Icon(Icons.qr_code_scanner,
                            color: Colors.white),
                        label: const Text(
                          "Scanner un QR réel",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// CRÉATION COMPTE
                      ElevatedButton.icon(
                        onPressed: _createAccount,
                        icon: const Icon(Icons.person_add),
                        label: const Text("Créer un compte"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[400],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
                        ),
                      ),
                    ],
                  )

                /// ---------------------------
                /// MODE CAMERA
                /// ---------------------------
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Scanner un QR Code...",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 300,
                        width: 300,
                        child: MobileScanner(
                          controller: MobileScannerController(
                            detectionSpeed: DetectionSpeed.noDuplicates,
                            facing: CameraFacing.back,
                          ),
                          onDetect: (capture) {
                            if (_navigationDone) return;

                            final barcode = capture.barcodes.first;
                            final code = barcode.rawValue;

                            if (code == null) return;

                            final parts = code.split(';');
                            final tableId = parts.isNotEmpty ? parts[0] : "T1";
                            final clientId =
                                parts.length > 1 ? parts[1] : "CLIENT_UNKNOWN";

                            _goToMenu(tableId, clientId);
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
