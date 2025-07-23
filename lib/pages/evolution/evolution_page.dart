import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/config/config.dart';
import 'package:sigma_new/config/config_loader.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/pages/usage_report/jee_mock_exam_details.dart';
import 'package:sigma_new/ui_helper/constant.dart';

import '../../utility/sd_card_utility.dart';
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
  List<String> courseList = [];

  @override
  void initState() {
    super.initState();
    //loadMockAttempts();
    // loadSubmissions();
    sharedPrefrenceData().then((_) {
      loadSubmissionsFromSDCard(); // only after courseList is ready
    });
    //loadMockAttemptsMock();
    // loadSubmissionsFromSDCard();
    loadAttemptsFromSDCard();
    loadFromSDCardAndDisplay();
  }

  sharedPrefrenceData() async {
    //  Config? config = await ConfigLoader.getGlobalConfig();
    final prefs = await SharedPreferences.getInstance();

    String? course = prefs.getString('course');
    print(
        "Standard${prefs.getString('class')} State:${prefs.getString('board')}");
    if (course != null && course.isNotEmpty) {
      courseList = course.split(","); // Convert String to List
    }
    print(courseList.length);
    print(courseList);
    // print("Class ${config!.class_![0]}");

    setState(() {});
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
    // await appendSubmissionsToSDCard(submissions);
    setState(() {});
  }

  Future<void> loadSubmissionsFromSDCard() async {
    try {
      final directory = await SdCardUtility.getBasePath();
      final filePath = '$directory/mock_exam.json';
      final file = File(filePath);

      if (await file.exists()) {
        final contents = await file.readAsString();
        final parsed = jsonDecode(contents);

        if (parsed is List) {
          final loadedSubmissions = parsed
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();

          print("CouseList $courseList");
          List<String> allowedClasses = courseList
              .map((course) {
                if (course.contains("10")) return "10";
                if (course.contains("12")) return "12";
                if (course.contains("JEE")) return "JEE"; // If needed
                return "";
              })
              .where((cls) => cls.isNotEmpty)
              .toList();

          // Filter based on courseList
          final filtered = loadedSubmissions.where((sub) {
            final stream = sub["questions"][0]["stream"]?.toString() ?? '';
            return allowedClasses.contains(stream);
          }).toList();

          print("Filtered $filtered");
          setState(() {
            submissions = filtered;
          });
        } else {
          print('File content is not a List');
          setState(() {
            submissions = [];
          });
        }



      } else {
        print('mock_exam.json not found');
        setState(() {
          submissions = [];
        });
      }
    } catch (e) {
      print('Error loading submissions: $e');
      setState(() {
        submissions = [];
      });
    }
  }

  String _extractSubjectFromTitle(String title) {
    // Example: "Board Mock Exam - Physics 1"
    final parts = title.split(' - ');
    if (parts.length >= 2) {
      final subjectPart = parts.last.trim(); // "Physics 1"
      final words = subjectPart.split(' ');
      return words.isNotEmpty ? words.first : "Unknown"; // "Physics"
    }
    return "Unknown";
  }

  final GlobalKey<ScaffoldState> _evolutionscaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Group submissions by subject (extracting subject from title)
    final Map<String, List<Map<String, dynamic>>> groupedSubmissions = {};

    for (var sub in submissions) {
      final title = sub['title'] ?? 'Untitled';
      final timestamp = sub['timestamp'] ?? '';
      final subject = _extractSubjectFromTitle(title); // custom function

      groupedSubmissions.putIfAbsent(subject, () => []).add(sub);
    }

    final List<Widget> children = [];

    groupedSubmissions.forEach((subject, subList) {
      // Subject header
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            subject,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
      );

      // Each mock under the subject
      for (var sub in subList) {
        final title = sub['title'] ?? 'Untitled';
        final timestamp = sub['timestamp'] ?? '';
        final dateTime = DateTime.tryParse(timestamp);

        children.add(
          ListTile(
            title: Text(title),
            subtitle: Text(
                dateTime != null ? '${dateTime.toLocal()}' : 'Unknown time'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MockExamDetailPage(
                    title: title,
                    timestamp: timestamp,
                    questions:
                        List<Map<String, dynamic>>.from(sub['questions']),
                  ),
                ),
              );
            },
          ),
        );
      }
    });

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
                // _buildStatsCard(context),
                /*Expanded(
                  child: submissions.isEmpty
                      ? const Center(child: Text("No submitted mocks found."))
                      : ListView.builder(
                          itemCount: submissions.length,
                          itemBuilder: (context, index) {
                            final sub = submissions[index];
                            print("Subject ${sub["questions"][0]["stream"]}");
                            final title = sub['title'] ?? 'Untitled';
                            final timestamp = sub['timestamp'] ?? '';
                            final dateTime = DateTime.tryParse(timestamp);

                            print("Titiel $title");
                            return ListTile(
                              title: Text("Class:${sub["questions"][0]["stream"]} $title"),
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
                ),*/

                Expanded(
                  child: submissions.isEmpty
                      ? const Center(child: Text("No submitted mocks found."))
                      : ListView(
                          children: children,
                        ),
                ),
              ],
            ),

            // Tab 2: JEE Subject
            SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Chapter")),
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
            ),
            // Tab 3: JEE Mock Exam

            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              style: black14BoldTextStyle.copyWith(
                                  color: Colors.blue),
                            ),
                            ...subjectEntry.value.map((attempt) {
                              final date =
                                  DateTime.tryParse(attempt['date'] ?? '')
                                          ?.toLocal() ??
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
                                  title: Text(
                                      "Score: $score/$total ($percentage%)"),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Date: ${date.toString().substring(0, 16)}"),
                                      Text("Wrong: $wrong | Time: $duration"),
                                    ],
                                  ),
                                  // trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => JeeMockExamDetails(
                                          subject: subjectEntry.key,
                                          //  attempts: subjectEntry.value,
                                          attempts: [attempt],
                                          title:
                                              subjectEntry.value.first["title"],
                                          date:
                                              date.toString().substring(0, 16),
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
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> loadAttemptsFromSDCard() async {
    final directory = await SdCardUtility.getBasePath();
    final dir = Directory(directory);
    final filePath = '$directory/mock_exam_attempts.json';

    final file = File(filePath);
    if (!(await file.exists())) {
      print("No saved attempts file found");
      return;
    }

    final content = await file.readAsString();
    final Map<String, dynamic> rawJson = jsonDecode(content);

    // Convert it into subject-wise grouped list
    Map<String, List<Map<String, dynamic>>> temp = {};

    rawJson.forEach((key, value) {
      // value can be either a Map or a List
      if (value is Map<String, dynamic>) {
        final subject = value['subjectId'] ?? value['subject'] ?? 'Unknown';
        temp.putIfAbsent(subject, () => []);
        temp[subject]!.add(value);
      } else if (value is List) {
        for (var item in value) {
          if (item is Map<String, dynamic>) {
            final subject = item['subjectId'] ?? item['subject'] ?? 'Unknown';
            temp.putIfAbsent(subject, () => []);
            temp[subject]!.add(item);
          }
        }
      }
    });

    // Sort each subject’s attempts by date descending
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

    print("Subject Attempts $subjectAttempts");
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

    print("Subject Attempts2 $subjectAttempts");
  }

  Future<void> loadFromSDCardAndDisplay() async {
    final data = await readMockAttemptsFromSDCard();
    setState(() {
      subjectAttemptsMock = data;
    });
  }

  Future<Map<String, List<Map<String, dynamic>>>>
      readMockAttemptsFromSDCard() async {
    try {
      final directory = await SdCardUtility.getBasePath();
      // final dir = Directory(directory);
      final filePath = '$directory/jee_exam_attempt.json';
      final file = File(filePath);

      if (await file.exists()) {
        final content = await file.readAsString();

        if (content.trim().isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is Map<String, dynamic>) {
            Map<String, List<Map<String, dynamic>>> parsedData = {};
            decoded.forEach((key, value) {
              if (value is List) {
                parsedData[key] =
                    value.whereType<Map<String, dynamic>>().toList();
              }
            });

            // Optional: Sort attempts by date
            parsedData.forEach((subject, attempts) {
              attempts.sort((a, b) {
                final dateA =
                    DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
                final dateB =
                    DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
                return dateB.compareTo(dateA);
              });
            });

            log("Loaded data from SD card: $parsedData");
            return parsedData;
          }
        }
      } else {
        debugPrint("File not found at: ${file.path}");
      }
    } catch (e) {
      debugPrint("Failed to read from SD card: $e");
    }

    return {};
  }
}
