import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('User belum login')),
      );
    }

    final riwayatRef = FirebaseFirestore.instance
        .collection('riwayat')
        .doc(uid)
        .collection('hasil')
        .orderBy('waktu', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Kuis')),
      body: StreamBuilder<QuerySnapshot>(
        stream: riwayatRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada riwayat kuis.'));
          }

          final riwayatList = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: riwayatList.length,
            itemBuilder: (context, index) {
              final data = riwayatList[index];
              final kategori = data['kategori'];
              final skor = data['skor'];
              final benar = data['benar'];
              final total = data['total'];
              final waktu = (data['waktu'] as Timestamp).toDate();

              return Card(
                child: ListTile(
                  title: Text(kategori),
                  subtitle: Text(
                    'Skor: $skor | Benar: $benar/$total\n${waktu.day}/${waktu.month}/${waktu.year} ${waktu.hour}:${waktu.minute}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
