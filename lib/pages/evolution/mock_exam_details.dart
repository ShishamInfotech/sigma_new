import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sigma_new/math_view/math_text.dart';

import '../text_answer/text_answer.dart';

class MockExamDetailPage extends StatelessWidget {
  final String title;
  final String timestamp;
  final List<Map<String, dynamic>> questions;

  const MockExamDetailPage({
    super.key,
    required this.title,
    required this.timestamp,
    required this.questions,
  });

  void showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content.isNotEmpty ? content : 'No data available.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {


    print("Questionss $questions");
    final date = DateTime.tryParse(timestamp)?.toLocal().toString() ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(title: Text("Mock Detail - $title")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text("Title: $title"),
            subtitle: Text("Submitted at: $date"),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final questionText = q['question'] ?? 'No question text';
                final answer = q['answer'].toString().toLowerCase()=="nr" ? q["test_answer_string"] : q['answer'];
                final explanation = q['explanation'] ?? '';
                final options = q['options'] ?? [];

                print("Explain $explanation");

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MathText(expression: 'Q${index + 1}: $questionText',
                            height: _estimateHeight(questionText),),
                        const SizedBox(height: 8),
                        if (options is List)
                          ...options.map<Widget>((opt) => Text('• $opt')).toList(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text("Answer"),
                             // onPressed: () => showInfoDialog(context, "Answer", answer),

                                onPressed: () {
                                  final isNR = q['test_answer_string'].toString().toLowerCase() == "nr";

                                  print("VALUEEE ${isNR && (q['description_image_id'].toString().toLowerCase() != "nr"
                                      || q['description_image_id'].toString().toLowerCase() != "na")}");
                                  if (isNR && (q['description_image_id'].toString().toLowerCase() != "nr"
                                                || q['description_image_id'].toString().toLowerCase() != "na")) {
                                    // Show image answer
                                    Get.to(TextAnswer(
                                      title: "Q${index + 1}. Answer",
                                      imagePath: q['description_image_id'],
                                      stream: q['stream'],
                                      basePath: "/${q["subjectid"]}/images/",
                                    ));
                                  } else {
                                    // Show text answer in dialog/snackbar/another screen
                                    Get.to(TextAnswer(
                                      title: title,
                                      imagePath:answer,stream: q['stream'] ,
                                        basePath:q['answer'].toString().toLowerCase()=="nr" ? "nr":"/${q["subjectid"]}/images/" ,));
                                  }
                                }

                            ),
                            const SizedBox(width: 10),
                           if(explanation!="") ElevatedButton.icon(
                              icon: const Icon(Icons.info_outline),
                              label: const Text("Explanation"),
                              onPressed: () =>
                                  showInfoDialog(context, "Explanation", explanation),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
