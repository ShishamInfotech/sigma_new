import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';



class StudyTrackerHomePage extends StatefulWidget {
  const StudyTrackerHomePage({super.key});

  @override
  State<StudyTrackerHomePage> createState() => _StudyTrackerHomePageState();
}

class _StudyTrackerHomePageState extends State<StudyTrackerHomePage> {


  Duration today = Duration.zero;
  Duration yesterday = Duration.zero;
  Duration total = Duration.zero;

  Duration average = Duration.zero;
  Duration lowest = Duration.zero;
  Duration highest = Duration.zero;

  var totalpercentageValue;
  var subjectName;
  var target_date;
  var stdClass;

  int videoCount = 0;
  int answerCount = 0;
  List<String> courseList=[];
  bool showJEE=false;
  Map<String, int> attemptCounts = {};
  bool isLoading = true;

  List<String> subjects = [];
  List<String> targetDate = [];
  List<String> subjectsId = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUsageData();
    printTotalPercentage();
    sharePreferenceData();
    _loadAttempts();
    subjectWiseTest();

  }



  subjectWiseTest() async {
    var newPath;
    var board;
    final prefs = await SharedPreferences.getInstance();
    String? course = prefs.getString('course');
    print(
        "Standard${prefs.getString('standard')} State:${prefs.getString('board')}");

    if (prefs.getString('board') == "Maharashtra") {
      board = "MH/";
    } else {
      board = prefs.getString('board');
    }

    if (prefs.getString('standard').toString().contains("10th")) {
      newPath = "10/";
    } else if (prefs.getString('standard').toString().contains("12th")) {
      newPath = "12/";
    }

    var inputFile = await SdCardUtility.getSubjectEncJsonData(
        '${newPath}${board}sigma_data.json');

    print("INput File  $inputFile");
    Map<String, dynamic> parsedJson = jsonDecode(inputFile!);
    // Extracting subject values
    List<dynamic> sigmaData = parsedJson["sigma_data"];

    // Get all subjects
    subjects = sigmaData.map((data) => data["subject"].toString()).toList();
    targetDate = sigmaData.map((data) => data["target_date"].toString()).toList();
    subjectsId = sigmaData.map((data) => data["subjectid"].toString()).toList();

    //removeTestSeriesFromSubjectTitle(subjects);

    // Print subjects
    stdClass = prefs.getString('standard').toString();
    print(subjects);
    setState(() {});
  }


  sharePreferenceData() async{
    final prefs = await SharedPreferences.getInstance();
    String? course = prefs.getString('course');
    print("Standard${prefs.getString('standard')} State:${prefs.getString('board')}");
    if (course != null && course.isNotEmpty) {
      courseList = course.split(","); // Convert String to List
    }
    setState(() {
      showJEE = courseList.any((exam) => exam.contains("JEE"));
    });

    print(showJEE);
  }


  printTotalPercentage() async{
    double totalPercentage = await getTotalPercentage();
    target_date = await getTargetCompletion();

    print('Total/Average Percentage: ${totalPercentage.toStringAsFixed(2)}%');

    totalpercentageValue = totalPercentage.toStringAsFixed(2);

   // await _storeChapterPercentage();

// Get specific chapter progress
//    double chapter1Progress = await getChapterPercentage('1');

// Get all progress


    Map<String, double> allSubjects = await getAllSubjectPercentages();
    allSubjects.forEach((subject, percentage) {

      subjectName =subject;
      print('$subject: $percentage%');
    });
  }

  Future<Map<String, double>> getAllSubjectPercentages() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('subject_')).toList();

    Map<String, double> subjectPercentages = {};

    for (String key in keys) {
      final subjectName = key.replaceFirst('subject_', '');
      subjectPercentages[subjectName] = prefs.getDouble(key) ?? 0.0;
    }

    return subjectPercentages;
  }


  Future<Map<String, double>> getAllChapterProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final storedChapters = prefs.getStringList('completed_chapters') ?? [];

    Map<String, double> progress = {};

    for (String key in storedChapters) {
      progress[key.replaceFirst('chapter_', '')] =
          prefs.getDouble(key) ?? 0.0;
    }

    return progress;
  }

  Future<double> getTotalPercentage() async {
    final prefs = await SharedPreferences.getInstance();
    final completedChapters = prefs.getStringList('completed_chapters') ?? [];

    if (completedChapters.isEmpty) return 0.0;

    double total = 0.0;

    for (String chapter in completedChapters) {
      double? percentage = prefs.getDouble('chapter_${chapter}_percentage');

      if (percentage != null) {
        total += percentage;
      }
    }

    // Return average percentage
    return total;

  }

  Future<String> getTargetCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final completedChapters = prefs.getStringList('completed_chapters') ?? [];

    if (completedChapters.isEmpty) return "";

    String target_date = "No Target Date";

    for (String chapter in completedChapters) {
       target_date = prefs.getString('chapter_${chapter}_percentage')!;


    }

    // Return average percentage
    return target_date;

  }


  String formatTime(Duration d) {
    return "${d.inHours}h ${d.inMinutes.remainder(60)}m";
  }

  Future<void> loadUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    String todayKey = "${now.year}-${now.month}-${now.day}";
    String yesterdayKey = "${now.year}-${now.month}-${now.day - 1}";

    int todayDuration = prefs.getInt(todayKey) ?? 0;
    int yesterdayDuration = prefs.getInt(yesterdayKey) ?? 0;

    Duration todayDurationObj = Duration(seconds: todayDuration);
    Duration yesterdayDurationObj = Duration(seconds: yesterdayDuration);
    Duration totalDuration = Duration.zero;

    List<int> durations = [];

    for (var key in prefs.getKeys()) {
      final value = prefs.get(key);
      if (value is int) {
        durations.add(value);
        totalDuration += Duration(seconds: value);
      }
    }

    durations.sort(); // To find lowest and highest easily

    Duration avg = durations.isNotEmpty
        ? Duration(seconds: durations.reduce((a, b) => a + b) ~/ durations.length)
        : Duration.zero;
    Duration min = durations.isNotEmpty ? Duration(seconds: durations.first) : Duration.zero;
    Duration max = durations.isNotEmpty ? Duration(seconds: durations.last) : Duration.zero;

    int videos = prefs.getInt('video_count') ?? 0;
    int answers = prefs.getInt('answer_count') ?? 0;

    setState(() {
      today = todayDurationObj;
      yesterday = yesterdayDurationObj;
      total = totalDuration;
      average = avg;
      lowest = min;
      highest = max;
      videoCount = videos;
      answerCount = answers;
    });
  }

  // Method to load mock exam results
  Future<List<Map<String, dynamic>>> _loadMockExamResults(bool isPCB) async {
    final prefs = await SharedPreferences.getInstance();
    final examAttemptsJson = prefs.getString('mock_exam_attempts') ?? '[]';
    final List<dynamic> examAttempts = jsonDecode(examAttemptsJson);

    // Filter results by PCB/PCM and sort by date
    return examAttempts
        .where((exam) => exam['isPCB'] == isPCB)
        .map((exam) => exam as Map<String, dynamic>)
        .toList()
        .reversed
        .toList();
  }

// Method to calculate stats for competitive exams
  Future<Map<String, dynamic>> _calculateExamStats(bool isPCB) async {
    final results = await _loadMockExamResults(isPCB);
    if (results.isEmpty) {
      return {
        'attempts': 0,
        'averageScore': 0.0,
        'highestScore': 0.0,
        'lowestScore': 0.0,
        'currentLevel': 'Not started',
      };
    }

    final scores = results.map((r) => double.parse(r['score'].toString())).toList();
    final average = scores.reduce((a, b) => a + b) / scores.length;
    final highest = scores.reduce((a, b) => a > b ? a : b);
    final lowest = scores.reduce((a, b) => a < b ? a : b);

    // Determine current level based on average score
    String currentLevel;
    if (average >= 95) {
      currentLevel = 'Advance';
    } else if (average >= 90) {
      currentLevel = 'Difficult';
    } else if (average >= 80) {
      currentLevel = 'Complex';
    } else if (average >= 70) {
      currentLevel = 'Medium';
    } else if (average >= 60) {
      currentLevel = 'Simple';
    } else {
      currentLevel = 'Simple';
    }

    return {
      'attempts': results.length,
      'averageScore': average,
      'highestScore': highest,
      'lowestScore': lowest,
      'currentLevel': currentLevel,
    };
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Time Monitoring Report'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStudyTimeSection(),
            const SizedBox(height: 24),
            totalpercentageValue=="" ? CircularProgressIndicator():_buildCourseProgressSection(),
            const SizedBox(height: 24),
            _buildTargetDatesSection(),
            const SizedBox(height: 24),
            _buildMockExamsSection(),
            const SizedBox(height: 24),
            if(showJEE)_buildCompetitiveExamsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyTimeSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Real Time Study Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCard('Yesterday', formatTime(yesterday)),
                _buildMetricCard('Today', formatTime(today)),
                _buildMetricCard('To Date', formatTime(total)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Analytical Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCard('Average', formatTime(average)),
                _buildMetricCard('Lowest', formatTime(lowest)),
                _buildMetricCard('Highest', formatTime(highest)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCard('Videos Watched', '$videoCount'),
                _buildMetricCard('Text Answer Visited', '$answerCount'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseProgressSection() {
    // Parse the percentage value safely
    final percentageValue = double.tryParse(totalpercentageValue ?? '0') ?? 0;
    final progressValue = percentageValue / 100;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${stdClass} Course Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progressValue, // This is now properly typed as double
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              'Overall: ${percentageValue.toStringAsFixed(1)}% (Pending ${(100 - percentageValue).toStringAsFixed(1)}%)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 100,
              child: FutureBuilder<Map<String, double>>(
                future: getAllSubjectPercentages(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final subject = snapshot.data!.keys.elementAt(index);
                      final percentage = snapshot.data![subject]!;

                      return ListTile(
                        title: Text(subject),
                        trailing: Text('${percentage.toStringAsFixed(1)}%'),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTargetDatesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${stdClass} Target Completion Dates ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              height: 500,
              child: FutureBuilder<Map<String, double>>(
                future: getAllSubjectPercentages(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                 // print("Target ${target_date}");
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      //print("Datta ${snapshot.data!.keys}");
                      /*var percentage=0.0;
                      if(snapshot.data!.keys!.isNotEmpty)
                        {
                        final subject = snapshot.data!.keys.elementAt(index);
                         percentage = snapshot.data![subject]!;
                         *//*setState(() {

                         });*//*
                        }

                     print("Target ${percentage}");


                      return _buildSubjectTarget(subjects[index], targetDate[index]== "null" ? "No Target Date" : targetDate[index], percentage );
*/

                      final subject = subjects[index]; // e.g., "Physics"
                      final target = targetDate[index] == "null" ? "No Target Date" : targetDate[index];

                      // Look up subject percentage from the snapshot
                      final percentage = snapshot.data?[subject] ?? 0.0;

                      return _buildSubjectTarget(subject, target, percentage);

                    },
                  );
                },
              ),
            ),
           // _buildSubjectTarget('Mathematics', 'Oct 31, 2025', 30),
          //  _buildSubjectTarget('Physics', 'Oct 31, 2025', 60),
          //  _buildSubjectTarget('Chemistry', 'Oct 31, 2025', 70),
          //  _buildSubjectTarget('Biology', 'Oct 31, 2025', 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectTarget(String subject, String date, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                date,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 70 ? Colors.green :
              progress >= 40 ? Colors.blue : Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text('$progress% completed'),
        ],
      ),
    );
  }

  Widget _buildMockExamsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Board Mock Exam Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            attemptCounts.isEmpty
                ? const Center(child: Text("No attempts recorded."))
                : Container(
                  height: 250,
                  child: ListView(
                                children: attemptCounts.entries.map((entry) {
                  return _buildExamPerformance(entry.key, entry.value, "Simple");
                                }).toList(),
                              ),
                ),
            const SizedBox(height: 8),
            const Text(
              'Performance Levels:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLevelIndicator('Simple', 'up to 60%'),
            _buildLevelIndicator('Medium', 'up to 70%'),
            _buildLevelIndicator('Complex', 'up to 80%'),
            _buildLevelIndicator('Difficult', 'up to 90%'),
            _buildLevelIndicator('Advance', 'up to 95%'),
          ],
        ),
      ),
    );
  }

  Widget _buildExamPerformance(String subject, int attempts, String level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(subject, style: TextStyle(
              fontSize: 16
            ),),
          ),
          Expanded(
            child: Row(
              children: [
                Text('Attempts: $attempts'),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getLevelColor(level),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    level,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelIndicator(String level, String range) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getLevelColor(level),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('$level: $range'),
        ],
      ),
    );
  }

  // Update the _buildCompetitiveExamsSection widget
  Widget _buildCompetitiveExamsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Competitive Exam Preparation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // PCM Section
            FutureBuilder<Map<String, dynamic>>(
              future: _calculateExamStats(false),
              builder: (context, snapshot) {
                final data = snapshot.data ?? {
                  'attempts': 0,
                  'averageScore': 0,
                  'highestScore': 0,
                  'lowestScore': 0,
                  'currentLevel': 'Not started',
                };

                return _buildExamPerformanceTable(
                  'JEE (PCM)',
                  'Physics, Chemistry, Mathematics',
                  data,
                );
              },
            ),

            const SizedBox(height: 16),

            // PCB Section (only show if PCB is enabled)
            if (showJEE)
              FutureBuilder<Map<String, dynamic>>(
                future: _calculateExamStats(true),
                builder: (context, snapshot) {
                  final data = snapshot.data ?? {
                    'attempts': 0,
                    'averageScore': 0,
                    'highestScore': 0,
                    'lowestScore': 0,
                    'currentLevel': 'Not started',
                  };

                  return _buildExamPerformanceTable(
                    'NEET (PCB)',
                    'Physics, Chemistry, Biology',
                    data,
                  );
                },
              ),

            const SizedBox(height: 8),
            const Text(
              'There will be five level Mock Examinations',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

// Helper widget to build exam performance table
  Widget _buildExamPerformanceTable(String exam, String subjects, Map<String, dynamic> data) {
    // Convert all numeric values to double
    final attempts = (data['attempts'] as int).toDouble();
    final averageScore = (data['averageScore'] as num).toDouble();
    final highestScore = (data['highestScore'] as num).toDouble();
    final lowestScore = (data['lowestScore'] as num).toDouble();
    final currentLevel = data['currentLevel'] as String;

    // Load mock exam results to count attempts per level
    final isPCB = exam.contains('PCB');

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadMockExamResults(isPCB),
      builder: (context, snapshot) {
        // Initialize level counters
        Map<String, int> levelCounts = {
          'Simple': 0,
          'Medium': 0,
          'Complex': 0,
          'Difficult': 0,
          'Advance': 0,
        };

        // Count attempts per level if we have data
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          for (var attempt in snapshot.data!) {
            final score = double.parse(attempt['score'].toString());
            String level;
            if (score >= 95) {
              level = 'Advance';
            } else if (score >= 90) {
              level = 'Difficult';
            } else if (score >= 80) {
              level = 'Complex';
            } else if (score >= 70) {
              level = 'Medium';
            } else {
              level = 'Simple';
            }
            levelCounts[level] = (levelCounts[level] ?? 0) + 1;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exam,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Subjects: $subjects',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            // Stats Header
            Container(
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text('Present Level', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Attempted', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Average Score', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Lowest Score', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Highest Score', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            // Stats Values
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      currentLevel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getLevelColor(currentLevel),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      attempts.toStringAsFixed(0),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${averageScore.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(averageScore),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${lowestScore.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(lowestScore),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${highestScore.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(highestScore),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Level attempts
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'Level Attempts:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (var level in ['Simple', 'Medium', 'Complex', 'Difficult', 'Advance'])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('Level $level'),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Attempted: ${levelCounts[level] ?? 0} times',
                        style: TextStyle(
                          color: level == currentLevel ? Colors.green : Colors.black,
                          fontWeight: level == currentLevel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Current Status: $currentLevel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getLevelColor(currentLevel),
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }

// Helper method to get color based on score
  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMetricCard(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'simple':
        return Colors.blue;
      case 'medium':
        return Colors.green;
      case 'complex':
        return Colors.orange;
      case 'difficult':
        return Colors.red;
      case 'advance':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }


  Future<void> _loadAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('mock_attempt_counts');

    if (data != null) {
      try {
        final parsed = Map<String, int>.from(jsonDecode(data));
        setState(() {
          attemptCounts = parsed;
          isLoading = false;
        });
      } catch (_) {
        setState(() {
          attemptCounts = {};
          isLoading = false;
        });
      }
    } else {
      setState(() {
        attemptCounts = {};
        isLoading = false;
      });
    }
  }
}