import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/qr_scanner_mobile_widget.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger .env
  await dotenv.load(fileName: ".env");

  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ton URL Firebase Realtime Database
  FirebaseDatabase.instance.databaseURL =
      "https://coffee-shop-ai-default-rtdb.europe-west1.firebasedatabase.app/";

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Coffee Shop AI",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.brown,
        useMaterial3: true,
      ),

      // 📌 Écran principal : scanner
      home: MobileQRScanner(
        clientHistory: {},
      ),

      // 📌 Pour éviter les erreurs de navigation
      routes: {
        "/chat": (_) => const ChatScreen(),
      },
    );
  }
}
