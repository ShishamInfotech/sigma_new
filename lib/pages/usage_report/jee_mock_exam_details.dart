import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/pages/text_answer/text_answer.dart';

class JeeMockExamDetails extends StatelessWidget {
  final String subject;
  final List<Map<String, dynamic>> attempts;
  final String title;
  final String date;

  const JeeMockExamDetails({
    super.key,
    required this.subject,
    required this.attempts,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attempts: $title")),
      body: ListView.builder(
        itemCount: attempts.length,
        itemBuilder: (context, index) {
          final attempt = attempts[index];
          final allQuestions = attempt['questions'] as List<dynamic>? ?? [];
          final chapter = attempt['chapter'] ?? 'Unknown';
          // Filter wrong answers first
          final wrongQuestions = allQuestions.where((q) => q['selected'] != q['correct']).toList();

          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 3,
            child: Column(
              children: [
                // Existing All Questions tile
                ExpansionTile(
                  title: Text(title),
                  subtitle: Text("Time: $date"),
                  children: [
                    QuestionList(
                      allQuestions: allQuestions,
                      chapter: chapter,
                    )
                  ],
                ),

                // Divider
                const Divider(height: 3, color: Colors.grey),

                // NEW Wrong Answers tile
                ExpansionTile(
                  title: Text("Wrong Answers (${wrongQuestions.length})"),
                  subtitle: const Text("Tap to view only wrong questions"),
                  initiallyExpanded: false,
                  children: [
                    QuestionList(
                      allQuestions: wrongQuestions,   // ← only wrong ones
                      chapter: chapter,
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class QuestionList extends StatefulWidget {
  final List<dynamic> allQuestions;
  final String chapter;

  const QuestionList({
    super.key,
    required this.allQuestions,
    required this.chapter,
  });

  @override
  State<QuestionList> createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  static const int batchSize = 5;
  late ScrollController _scrollController;
  int currentMaxIndex = 5;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (currentMaxIndex < widget.allQuestions.length) {
        setState(() {
          currentMaxIndex = (currentMaxIndex + batchSize)
              .clamp(0, widget.allQuestions.length);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedQuestions = widget.allQuestions.take(currentMaxIndex).toList();

    return SizedBox(
      height: MediaQuery.sizeOf(context).height, // Fixed height to allow scrolling
      child: ListView.builder(
        controller: _scrollController,
        itemCount: displayedQuestions.length,
        itemBuilder: (context, index) {
          final q = displayedQuestions[index];
          final questionText = q['question'] ?? 'No Question';
          final selected = q['selected'] ?? 'Not Answered';
          final correct = q['correct'] ?? 'Unknown';
          final answerExplanation = q['text_answer'] ?? 'No explanation available';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MathText(
                  expression: "Q${index + 1}: $questionText",
                  height: _estimateHeight(questionText),
                ),
                const SizedBox(height: 4),
                MathText(
                  expression:
                  'Your Answer: <span style="color:${selected == correct ? 'green' : 'red'};">$selected</span>',
                  height: 80,
                ),


                MathText(
                  expression: 'Correct Answer: <span style="color:green;">$correct</span>',
                  height: 80,
                ),

                ElevatedButton(
                  onPressed: () {
                    Get.to(TextAnswer(
                      imagePath: answerExplanation,
                      title: "Q${index + 1}. Answer",
                      basePath: "nr",
                    ));
                  },
                  child: const Text("Show Answer"),
                ),
                const Divider(),
              ],
            ),
          );
        },
      ),
    );
  }

  double _estimateHeight(String text) {
    if (text.isEmpty) return 0;

    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath =
        text.contains(r'\frac') || text.contains(r'\sqrt') || text.contains(r'\(');

    double height = (lines + longLines) * 30.0;
    height = height * 5.0;

    if (hasComplexMath) {
      height += 30.0;
    }

    return height.clamp(50.0, 300.0);
  }
}
