import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/ui_helper/constant.dart';

import '../usage_report/mock_exam_detail_page.dart';
import 'mock_exam_details.dart'; // You'll create this next

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({super.key});

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  List<Map<String, dynamic>> submissions = [];
  Map<String, List<Map<String, dynamic>>> subjectAttempts = {};
  Map<String, List<Map<String, dynamic>>> subjectAttemptsMock = {};

  @override
  void initState() {
    super.initState();
    loadMockAttempts();
    loadSubmissions();
    loadMockAttemptsMock();
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

  final GlobalKey<ScaffoldState> _evolutionscaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _evolutionscaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(

          title: const Text("Evaluation Bucket",
              style: black20w400MediumTextStyle),
          backgroundColor: backgroundColor,
          bottom: const TabBar(
            labelColor: primaryColor,
            unselectedLabelColor: Colors.black54,
            indicatorColor: primaryColor,
            tabs: [
              Tab(text: "Mock Exam"),
              Tab(text: "JEE Subject"),
              Tab(text: "JEE Mock Exam"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            // Tab 1: Mock Exam
            Column(
              children: [
                //_buildStatsCard(context),
                Expanded(
                  child: submissions.isEmpty
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
                                      questions:
                                          List<Map<String, dynamic>>.from(
                                              sub['questions']),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),

            // Tab 2: JEE Subject
            DataTable(
              columns: const [
                DataColumn(label: Text("Subject")),
                DataColumn(label: Text("Attempts")),
                // DataColumn(label: Text("Best Score")),
              ],
              rows: subjectAttempts.entries.map((entry) {
                // Find best score for this subject

                return DataRow(
                  cells: [
                    DataCell(
                      Text(entry.key),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MockExamDetailPageReport(
                                subject: entry.key, attempts: entry.value),
                          ),
                        );
                      },
                    ),
                    DataCell(Text("${entry.value.length}")),
                    //DataCell(Text("$bestScore/$totalQuestions")),
                  ],
                );
              }).toList(),
            ),

            // Tab 3: JEE Mock Exam
            Container(
              margin: EdgeInsets.symmetric(horizontal:10 ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (subjectAttemptsMock.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text("No exam attempts found",
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ...subjectAttemptsMock.entries.expand((subjectEntry) {
                    return [
                      const SizedBox(height: 8),
                      Text(
                        subjectEntry.value.first["title"],
                        style: black14BoldTextStyle.copyWith(color: Colors.blue),
                      ),
                      ...subjectEntry.value.map((attempt) {
                        final date =
                            DateTime.tryParse(attempt['date'] ?? '')?.toLocal() ??
                                DateTime.now();
                        final score = attempt['correct'] ?? 0;
                        final total = attempt['total'] ?? 1;
                        final wrong = attempt['wrong'] ?? 0;
                        final percentage =
                            (score / total * 100).toStringAsFixed(1);
                        final duration = attempt['duration'] ?? 'N/A';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text("Score: $score/$total ($percentage%)"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Date: ${date.toString().substring(0, 16)}"),
                                Text("Wrong: $wrong | Time: $duration"),
                              ],
                            ),
                            // trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MockExamDetailPageReport(
                                    subject: subjectEntry.key,
                                    attempts: subjectEntry.value,
                                    //  selectedAttempt: attempt,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ];
                  }).toList(),
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationStat(String label, String value, String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(assetPath),
          Text(label, style: black10MediumTextStyle),
          Text(value, style: primaryColor18BoldTextStyle),
        ],
      ),
    );
  }

  Widget _divider(double height) {
    return SizedBox(
      height: height * 0.08,
      child: const VerticalDivider(
        color: primaryColor,
        thickness: 1,
        width: 15,
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Card(
      elevation: 6,
      shadowColor: primaryColor,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEvaluationStat(
                "Completed", "10", "assets/svg/completed_evaluation.svg"),
            _divider(height),
            _buildEvaluationStat(
                "Total Score", "10", "assets/svg/totalscore_evaluation.svg"),
            _divider(height),
            _buildEvaluationStat(
                "Average", "10", "assets/svg/averge_evaluation.svg"),
            _divider(height),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                        "assets/svg/subjectwisetest_evaluation.svg"),
                    const Text("Current Test Level",
                        style: black10MediumTextStyle),
                    Text("Simple", style: primaryColor16MediumTextStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadMockAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<Map<String, dynamic>>> temp = {};
    final now = DateTime.now();

    /*final attemptsJson = prefs.getString('total_mock_exam_attempts') ?? '[]';
    final List<dynamic> attempts = jsonDecode(attemptsJson);
    print("ATtemptss $attempts");*/

    for (var key in prefs.getKeys()) {
      if (key.startsWith('offline_quiz_')) {
        final jsonStr = prefs.getString(key);
        if (jsonStr != null) {
          try {
            final decoded = jsonDecode(jsonStr);

            // Handle both single attempt and list of attempts
            if (decoded is Map<String, dynamic>) {
              print("Decoded $decoded");
              final subject =
                  decoded['subjectId'] ?? decoded['subject'] ?? 'Unknown';
              temp.putIfAbsent(subject, () => []);
              temp[subject]!.add(decoded);
            } else if (decoded is List) {
              for (var attempt in decoded) {
                if (attempt is Map<String, dynamic>) {
                  print("Attempt $attempt");
                  final subject =
                      attempt['subjectId'] ?? attempt['subject'] ?? 'Unknown';
                  temp.putIfAbsent(subject, () => []);
                  temp[subject]!.add(attempt);
                }
              }
            }
          } catch (e) {
            debugPrint("Error parsing $key: $e");
          }
        }
      }
    }

    // Sort attempts by date (newest first)
    temp.forEach((subject, attempts) {
      attempts.sort((a, b) {
        final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
        final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });
    });

    setState(() {
      subjectAttempts = temp;
    });
  }

  Future<void> loadMockAttemptsMock() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<Map<String, dynamic>>> temp = {};
    final now = DateTime.now();

    /*final attemptsJson = prefs.getString('total_mock_exam_attempts') ?? '[]';
    final List<dynamic> attempts = jsonDecode(attemptsJson);
    print("ATtemptss $attempts");*/

    for (var key in prefs.getKeys()) {
      if (key.startsWith('mock_exam_attempts')) {
        final jsonStr = prefs.getString(key);
        if (jsonStr != null) {
          try {
            final decoded = jsonDecode(jsonStr);

            // Handle both single attempt and list of attempts
            if (decoded is Map<String, dynamic>) {
              print("Decoded $decoded");
              final subject =
                  decoded['subjectId'] ?? decoded['subject'] ?? 'Unknown';
              temp.putIfAbsent(subject, () => []);
              temp[subject]!.add(decoded);
            } else if (decoded is List) {
              for (var attempt in decoded) {
                if (attempt is Map<String, dynamic>) {
                  print("Attempt $attempt");
                  final subject =
                      attempt['subjectId'] ?? attempt['subject'] ?? 'Unknown';
                  temp.putIfAbsent(subject, () => []);
                  temp[subject]!.add(attempt);
                }
              }
            }
          } catch (e) {
            debugPrint("Error parsing $key: $e");
          }
        }
      }
    }

    // Sort attempts by date (newest first)
    temp.forEach((subject, attempts) {
      attempts.sort((a, b) {
        final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
        final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });
    });

    setState(() {
      subjectAttemptsMock = temp;
    });
  }
}
