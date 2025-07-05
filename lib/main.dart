import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizapp/firebase_options.dart';
import 'package:quizapp/screens/topik_detail_screen.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await uploadSemuaJSON(); // ⬅️ tidak akan overwrite jika data sudah ada

  runApp(const MyApp());
}

// 📦 Cek dulu apakah dokumen sudah ada
Future<void> uploadJSON(String filename, String docId) async {
  final docRef = FirebaseFirestore.instance.collection('quizzes').doc(docId);
  final existing = await docRef.get();

  if (existing.exists) {
    debugPrint("ℹ️ [$docId] sudah ada di Firestore. Lewati upload.");
    return;
  }

  try {
    final jsonStr = await rootBundle.loadString('assets/$filename');
    final data = json.decode(jsonStr);
    await docRef.set(data);
    debugPrint("✅ [$docId] berhasil di-upload");
  } catch (e) {
    debugPrint("❌ Gagal upload [$docId]: $e");
  }
}

Future<void> uploadSemuaJSON() async {
  await uploadJSON('rekayasa_perangkat_lunak.json', 'rekayasa_perangkat_lunak');
  await uploadJSON(
    'interaksi_manusia_komputer.json',
    'interaksi_manusia_komputer',
  );
  await uploadJSON('pemrograman_mobile.json', 'pemrograman_mobile');
  await uploadJSON('pemrograman_web_2.json', 'pemrograman_web_2');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.hasData ? const HomeScreen() : const LoginScreen();
        },
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
