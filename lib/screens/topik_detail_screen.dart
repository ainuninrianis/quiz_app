import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class TopikDetailScreen extends StatelessWidget {
  final String topik;

  const TopikDetailScreen({super.key, required this.topik});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> deskripsiTopik = {
      'Interaksi Manusia dan Komputer':
          '🧠 IMK membahas bagaimana pengguna berinteraksi dengan sistem digital melalui antarmuka yang intuitif dan efisien. Kamu akan mengenal konsep UI, usability, evaluasi antarmuka, dan prototype.',
      'Pemrograman Mobile':
          '📱 Flutter adalah framework dari Google untuk membangun aplikasi Android & iOS dari satu basis kode. Kamu akan belajar tentang widget, state, navigasi, dan plugin.',
      'Pemrograman Web 2':
          '🕸️ Pelajari HTML, CSS, dan JavaScript untuk membuat web yang interaktif dan responsif. Kamu juga akan mengenal konsep DOM, fetch API, dan hosting.',
      'Rekayasa Perangkat Lunak':
          '💻 Topik ini menjelaskan proses pengembangan software dari awal hingga deploy. Termasuk konsep SDLC, debugging, UML, version control, dan metode Agile.'
    };

    final String isiDeskripsi =
        deskripsiTopik[topik] ?? '📘 Belum ada deskripsi untuk topik ini.';

    return Scaffold(
      appBar: AppBar(title: Text("Topik: $topik")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📝 Tentang Topik Ini",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(
              isiDeskripsi,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text("Mulai Quiz"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(topik: topik),
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
