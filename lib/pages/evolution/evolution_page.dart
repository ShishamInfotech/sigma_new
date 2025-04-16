import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_exam_details.dart'; // You'll create this next

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({super.key});

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  List<Map<String, dynamic>> submissions = [];

  @override
  void initState() {
    super.initState();
    loadSubmissions();
  }

  Future<void> loadSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('mock_submissions');
    if (stored != null) {
      try {
        final parsed = jsonDecode(stored) as List;
        submissions = parsed.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (_) {
        submissions = [];
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Evaluation")),
      body: submissions.isEmpty
          ? const Center(child: Text("No submitted mocks found."))
          : ListView.builder(
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          final sub = submissions[index];
          final title = sub['title'] ?? 'Untitled';
          final timestamp = sub['timestamp'] ?? '';
          final dateTime = DateTime.tryParse(timestamp);

          return ListTile(
            title: Text(title),
            subtitle: Text(dateTime != null
                ? '${dateTime.toLocal()}'
                : 'Unknown time'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MockExamDetailPage(
                    title: title,
                    timestamp: timestamp,
                    questions: List<Map<String, dynamic>>.from(sub['questions']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
