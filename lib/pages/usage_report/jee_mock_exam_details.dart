import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/pages/text_answer/text_answer.dart';

class JeeMockExamDetails extends StatefulWidget {
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
  State<JeeMockExamDetails> createState() => _JeeMockExamDetailsState();
}

class _JeeMockExamDetailsState extends State<JeeMockExamDetails> {
  static const int batchSize = 5;
  int currentMaxIndex = 5;

  @override
  Widget build(BuildContext context) {
    final displayedAttempts = widget.attempts.take(currentMaxIndex).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Attempts: ${widget.title}")),
      body: ListView.builder(
        itemCount: displayedAttempts.length + 1, // +1 for Load More button
        itemBuilder: (context, index) {
          if (index == displayedAttempts.length) {
            // Load More Button
            return Visibility(
              visible: currentMaxIndex < widget.attempts.length,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentMaxIndex = (currentMaxIndex + batchSize)
                            .clamp(0, widget.attempts.length);
                      });
                    },
                    child: Text("Load More"),
                  ),
                ),
              ),
            );
          }

          final attempt = displayedAttempts[index];
          final questions = attempt['questions'] as List<dynamic>? ?? [];
          final chapter = attempt['chapter'] ?? 'Unknown';
          final timestamp = attempt['timestamp'] ?? '';

          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 3,
            child: ExpansionTile(
              title: Text("${widget.title}"),
              subtitle: Text("Time: ${widget.date}"),
              children: questions.asMap().entries.map((entry) {
                final qIndex = entry.key + 1;
                final q = entry.value;

                final questionText = q['question'] ?? 'No Question';
                final selected = q['selected'] ?? 'Not Answered';
                final correct = q['correct'] ?? 'Unknown';
                final answerExplanation =
                    q['text_answer'] ?? 'No explanation available';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MathText(
                        expression: "Q$qIndex: $questionText",
                        height: _estimateHeight(questionText),
                      ),
                      const SizedBox(height: 4),
                      MathText(expression: "Your Answer: $selected", height: 80),
                      MathText(expression: "Correct Answer: $correct", height: 80),

                      ElevatedButton(
                        onPressed: () {
                          Get.to(TextAnswer(
                            imagePath: answerExplanation,
                            title: chapter,
                            basePath: "nr",
                          ));
                        },
                        child: const Text("Show Answer"),
                      ),
                      const Divider(),
                    ],
                  ),
                );
              }).toList(),
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
