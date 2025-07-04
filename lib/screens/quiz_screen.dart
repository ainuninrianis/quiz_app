import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizScreen extends StatefulWidget {
  final String topik;

  const QuizScreen({super.key, required this.topik});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> questions = [];
  int currentIndex = 0;
  String? selectedAnswer;
  bool isLoading = true;
  late int endTime;
  late List<int?> userAnswers;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final docId = widget.topik.toLowerCase().replaceAll(' ', '_');
    final snapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(docId)
        .get();

    final data = snapshot.data();
    debugPrint("📘 DocID: $docId");
    debugPrint("📄 Data: ${data != null ? '✅ ditemukan' : '⛔ null'}");

    if (data == null || data['soal'] == null) {
      setState(() {
        questions = [];
        isLoading = false;
      });
      return;
    }

    try {
      final List soal = data['soal'];
      setState(() {
        questions = soal
            .map<Map<String, dynamic>>((q) => Map<String, dynamic>.from(q))
            .toList();
        isLoading = false;

        userAnswers = List.filled(questions.length, null);
        endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 30 * questions.length;
      });
    } catch (e) {
      debugPrint("❗ Error parsing soal: $e");
      setState(() {
        questions = [];
        isLoading = false;
      });
    }
  }

  void _nextQuestion() {
    if (selectedAnswer != null) {
      final options = List<String>.from(questions[currentIndex]['opsi'] ?? []);
      userAnswers[currentIndex] = options.indexOf(selectedAnswer!);
    }

    setState(() {
      currentIndex++;
      if (userAnswers[currentIndex] != null) {
        final options = List<String>.from(questions[currentIndex]['opsi'] ?? []);
        selectedAnswer = options[userAnswers[currentIndex]!];
      } else {
        selectedAnswer = null;
      }
    });
  }

  

  void _finishQuiz() {
    if (!mounted) return;

    if (selectedAnswer != null) {
      final options = List<String>.from(questions[currentIndex]['opsi'] ?? []);
      userAnswers[currentIndex] = options.indexOf(selectedAnswer!);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FinishScreen(
          questions: questions,
          userAnswers: userAnswers,
          topik: widget.topik,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz: ${widget.topik}")),
        body: const Center(
          child: Text(
            "❌ Tidak ada soal untuk topik ini.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final currentQuestion = questions[currentIndex];
    final options = List<String>.from(currentQuestion['opsi'] ?? []);
    final questionText = currentQuestion['pertanyaan'] ?? 'Soal tidak tersedia';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Topik: ${widget.topik}",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CountdownTimer(
                endTime: endTime,
                onEnd: _finishQuiz,
                textStyle: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Soal ${currentIndex + 1}/${questions.length}",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              questionText,
              style: GoogleFonts.poppins(fontSize: 20),
            ),
            const SizedBox(height: 24),
            ...options.map((option) => RadioListTile<String>(
                  value: option,
                  groupValue: selectedAnswer,
                  title: Text(option, style: GoogleFonts.poppins()),
                  activeColor: const Color.fromARGB(255, 106, 156, 236),
                  onChanged: (value) {
                    setState(() {
                      selectedAnswer = value;
                    });
                  },
                )),
            const Spacer(),
            ElevatedButton(
              onPressed: selectedAnswer == null
                  ? null
                  : () {
                      if (currentIndex + 1 < questions.length) {
                        _nextQuestion();
                      } else {
                        _finishQuiz();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 121, 177, 240),
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                currentIndex + 1 < questions.length ? "Selanjutnya" : "Selesai",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FinishScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<int?> userAnswers;
  final String topik;

  const FinishScreen({
    Key? key,
    required this.questions,
    required this.userAnswers,
    required this.topik,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      final correctAnswerIndex = questions[i]['jawabanIndex'];
      if (userAnswers[i] == correctAnswerIndex) {
        correctAnswers++;
      }
    }

    double score = (correctAnswers / questions.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Quiz: $topik', style: GoogleFonts.poppins()),
        backgroundColor: const Color.fromARGB(255, 126, 204, 241),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.deepPurple.shade50,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Skor Akhir Kamu',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${score.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 121, 188, 250),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Benar $correctAnswers dari ${questions.length} soal',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final userAnswerIndex = userAnswers[index];
                final correctAnswerIndex = question['jawabanIndex'];
                final options = List<String>.from(question['opsi'] ?? []);
                final isCorrect = userAnswerIndex == correctAnswerIndex;
                final penjelasan = question['penjelasan'] ?? '';

                return Card(
                  color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ExpansionTile(
                    leading: Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      question['pertanyaan'] ?? 'Soal tidak tersedia',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userAnswerIndex != null
                                  ? 'Jawabanmu: ${options[userAnswerIndex]}'
                                  : 'Tidak dijawab',
                              style: GoogleFonts.poppins(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (!isCorrect)
                              Text(
                                'Jawaban benar: ${options[correctAnswerIndex]}',
                                style: GoogleFonts.poppins(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            if (penjelasan.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Penjelasan:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                penjelasan,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: Text('Kembali ke Halaman Utama', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 117, 174, 248),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
        
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> simpanRiwayatKuis({
  required String kategori,
  required int skor,
  required int benar,
  required int total,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  await FirebaseFirestore.instance
      .collection('riwayat')
      .doc(uid)
      .collection('hasil')
      .add({
    'kategori': kategori,
    'skor': skor,
    'benar': benar,
    'total': total,
    'waktu': Timestamp.now(),
  });
}