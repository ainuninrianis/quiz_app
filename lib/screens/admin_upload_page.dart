import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUploadPage extends StatelessWidget {
  const AdminUploadPage({super.key});

  Future<void> uploadJSON(String filename, String docId) async {
    final jsonStr = await rootBundle.loadString('assets/$filename');
    final data = json.decode(jsonStr);
    await FirebaseFirestore.instance.collection('quizzes').doc(docId).set(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Soal ke Firestore")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await uploadJSON('rekayasa_perangkat_lunak.json', 'rekayasa_perangkat_lunak');
                await uploadJSON('interaksi_manusia_komputer.json', 'interaksi_manusia_komputer');
                await uploadJSON('pemrograman_mobile.json', 'pemrograman_mobile');
                await uploadJSON('pemrograman_web_2.json', 'pemrograman_web_2');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Semua soal berhasil diupload!")),
                );
              },
              child: const Text("Upload Semua Topik"),
            ),
          ],
        ),
      ),
    );
  }
}
