import 'package:flutter/material.dart';
import 'topik_detail_screen.dart';
import 'history_screen.dart'; // 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<String> topikList = const [
    "Rekayasa Perangkat Lunak",
    "Interaksi Manusia Komputer",
    "Pemrograman Mobile",
    "Pemrograman Web 2"
  ];

  final Map<String, IconData> topikIkon = const {
    "Rekayasa Perangkat Lunak": Icons.code,
    "Interaksi Manusia Komputer": Icons.psychology, // ← perbaiki dari "dan"
    "Pemrograman Mobile": Icons.smartphone,
    "Pemrograman Web 2": Icons.language,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Topik Mata Kuliah TI"),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Riwayat Kuis',
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Silakan pilih topik yang ingin kamu pelajari:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: topikList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final topik = topikList[index];
                  final icon = topikIkon[topik] ?? Icons.book;

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
                      ),
                      title: Text(
                        topik,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TopikDetailScreen(topik: topik),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
