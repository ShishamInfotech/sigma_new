import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/pages/text_answer/text_answer.dart';

class MockExamDetailPageReport extends StatelessWidget {
  final String subject;
  final List<Map<String, dynamic>> attempts;

  const MockExamDetailPageReport({
    super.key,
    required this.subject,
    required this.attempts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attempts: $subject")),
      body: ListView.builder(
        itemCount: attempts.length,
        itemBuilder: (context, index) {
          final attempt = attempts[index];
          final questions = attempt['questions'] as List<dynamic>? ?? [];
          final chapter = attempt['chapter'] ?? 'Unknown';
          final timestamp = attempt['timestamp'] ?? '';

          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 3,
            child: ExpansionTile(
              title: Text("Attempt ${index + 1} - Chapter: $chapter"),
              subtitle: Text("Time: $timestamp"),
              children: questions.asMap().entries.map((entry) {
                final qIndex = entry.key + 1;
                final q = entry.value;

                final questionText = q['question'] ?? 'No Question';
                final selected = q['selected'] ?? 'Not Answered';
                final correct = q['correct'] ?? 'Unknown';
                final answerExplanation = q['text_answer'] ?? 'No explanation available';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MathText(expression: "Q$qIndex: $questionText", height: _estimateHeight(questionText),),
                      const SizedBox(height: 4),
                      MathText(expression: "Your Answer: $selected", height: 80),
                      MathText(expression: "Correct Answer: $correct", height: 80),

                      // Answer button and explanation
                      StatefulBuilder(
                        builder: (context, setState) {
                          bool showAnswer = false;
                          return Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Get.to(TextAnswer(imagePath: answerExplanation, title: "Q$qIndex. Answer",basePath: "nr",));
                                },
                                child: Text("Show Answer"),
                              ),

                            ],
                          );
                        },
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
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt') || text.contains(r'\(');

    double height = (lines + longLines) * 30.0;
    height = height * 5.0;

    if (hasComplexMath) {
      height += 30.0;
    }

    return height.clamp(50.0, 300.0);
  }
}