import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'quiz_screen.dart';

class TopikDetailScreen extends StatelessWidget {
  final String topik;

  const TopikDetailScreen({super.key, required this.topik});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> deskripsiTopik = {
      'Interaksi Manusia Komputer': // fix: samakan dengan topik yang dikirim
          '🧠 IMK membahas bagaimana pengguna berinteraksi dengan sistem digital melalui antarmuka yang intuitif dan efisien. Kamu akan mengenal konsep UI, usability, evaluasi antarmuka, dan prototype.',
      'Pemrograman Mobile':
          '📱 Flutter adalah framework dari Google untuk membangun aplikasi Android & iOS dari satu basis kode. Kamu akan belajar tentang widget, state, navigasi, dan plugin.',
      'Pemrograman Web 2':
          '🕸️ Pelajari HTML, CSS, dan JavaScript untuk membuat web yang interaktif dan responsif. Kamu juga akan mengenal konsep DOM, fetch API, dan hosting.',
      'Rekayasa Perangkat Lunak':
          '💻 Topik ini menjelaskan proses pengembangan software dari awal hingga deploy. Termasuk konsep SDLC, debugging, UML, version control, dan metode Agile.',
    };

    final String isiDeskripsi =
        deskripsiTopik[topik] ?? '📘 Belum ada deskripsi untuk topik ini.';

    return Scaffold(
      backgroundColor: const Color(0xFFF4EEFF),
      appBar: AppBar(
        title: Text(
          "Topik: $topik",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple[300],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.menu_book_rounded,
                size: 80,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "📝 Tentang Topik Ini",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  isiDeskripsi,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text("Mulai Quiz"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
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
