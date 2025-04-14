import 'package:flutter/material.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final String subject;
  final List<Map<String, dynamic>> subjectDataList;

  const SubjectDetailsScreen({super.key, required this.subject, required this.subjectDataList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Subject: $subject',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ...subjectDataList.map((subjectData) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chapter: ${subjectData['chapter']}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Subchapter: ${subjectData['subchapter']}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Description: ${subjectData['description'] ?? 'No description available.'}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 6),
                        // Add more fields as necessary
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
