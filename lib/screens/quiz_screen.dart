import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    setState(() {
      selectedAnswer = null;
      currentIndex++;
    });
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
      appBar: AppBar(title: Text("Topik: ${widget.topik}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Soal ${currentIndex + 1}/${questions.length}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              questionText,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            ...options.map((option) => RadioListTile<String>(
                  value: option,
                  groupValue: selectedAnswer,
                  title: Text(option),
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
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Quiz Selesai 🎉"),
                            content: const Text("Kamu sudah menyelesaikan semua soal."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Oke"),
                              )
                            ],
                          ),
                        );
                      }
                    },
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
