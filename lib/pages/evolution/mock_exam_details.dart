import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
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
                return ListTile(
                  title: Text('Q${index + 1}: ${q['question'] ?? 'No question text'}'),
                  subtitle: q.containsKey('options')
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      (q['options'] as List).length,
                          (i) => Text('• ${q['options'][i]}'),
                    ),
                  )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
