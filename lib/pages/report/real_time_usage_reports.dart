import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
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
  Map<String, dynamic> attemptCounts = {};
  bool isLoading = true;

  List<String> subjects = [];
  List<String> targetDate = [];
  List<String> subjectsId = [];

  Map<String, int> titleCountMap = {};



  Map<String, dynamic> _targetDateMap = {};
  Map<String, dynamic> _mockExamMap = {};
  Map<String, dynamic> _competitiveExamMap = {};
  Map<String, dynamic> _metadata = {};

  List<Map<String, dynamic>> submissions = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*loadUsageData();
    printTotalPercentage();
    sharePreferenceData();
    _loadAttempts();
    subjectWiseTest();


    //fetchStudyTrackerData();

    loadDataFromMemoryCard();

    saveAllDataToMemoryCard();*/

    initializeAndSave();

  }


  void initializeAndSave() async {
    // Step 1: Load and calculate all data you want to save
    await loadUsageData();         // Populate usage data (today, total, etc.)
    //await printTotalPercentage();  // Calculate total % progress
    await sharePreferenceData();   // Load shared prefs like videoCount, etc.
         // Load attempts for mock/quiz
    await subjectWiseTest();       // Load subject-wise performance

    // Step 2: Now that all data is ready, save it
    await saveAllDataToMemoryCard();

    await loadSubmissionsFromSDCard();

    _loadAllExamAttempts();

    // Step 3: Then load data back if needed
    await loadDataFromMemoryCard();
    //await _loadAttempts();
  }


  void _loadAllExamAttempts() async {
    final allStats = await readAllExamStats();

    if (allStats.isEmpty) {
      print("No stats found.");
      return;
    }

    print("AL Lenght ${allStats}");
    allStats.forEach((category, attempts) {
      print("📘 Category: $category");
      for (var attempt in attempts) {
        print("  - Score: ${attempt['averageScore']}, Level: ${attempt['currentLevel']}, Time: ${attempt['timestamp']}");
      }
    });
  }

  Future<void> fetchStudyTrackerData() async {
    final directory = await SdCardUtility.getBasePath(); // Your custom utility
    final dir = Directory(directory);
    final filePath = '$directory/study_tracker_data.json';
    final file = File(filePath);

    if (await dir.exists()) {
      if (await file.exists()) {
        try {
          final contents = await file.readAsString();
          final jsonData = jsonDecode(contents);
          print('Fetched Data: $jsonData');
        //  loadDataFromMemoryCard();
          // Use jsonData here...
        } catch (e) {
          print('Error reading JSON file: $e');
        }
      } else {
        print('File does not exist at: $filePath');
       // saveAllDataToMemoryCard();
      }
    } else {
      print('Directory does not exist: $directory');
      //saveAllDataToMemoryCard();
    }
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

    print("Completed Chap $completedChapters");
    for (String chapter in completedChapters) {
       target_date = prefs.getString('chapter_${chapter.toString()}_percentage')!;

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

   // saveAllDataToMemoryCard();
  }


  // Method to load mock exam results
  Future<List<Map<String, dynamic>>> _loadMockExamResults(bool isPCB) async {
    final prefs = await SharedPreferences.getInstance();
    final examAttemptsJson = prefs.getString('mock_exam_attempts') ?? '[]';
    final List<dynamic> examAttempts = jsonDecode(examAttemptsJson);

    print("Exam Attempts $examAttempts");
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

    print("Calculate $results");
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

    final level = results.elementAt(0)['level'].toString();
    // Determine current level based on average score
    String currentLevel;
    if (level == 'a') {
      currentLevel = 'Advance';
    } else if (level == 'd') {
      currentLevel = 'Difficult';
    } else if (level == 'c') {
      currentLevel = 'Complex';
    } else if (level == 'm') {
      currentLevel = 'Medium';
    } else if (level == 's') {
      currentLevel = 'Simple';
    } else {
      currentLevel = 'Simple';
    }



    final resultMap = {
      'attempts': results.length,
      'averageScore': average,
      'highestScore': highest,
      'lowestScore': lowest,
      'currentLevel': currentLevel,
    };

    await appendExamStat(isPCB ? 'pcb' : 'pcm', resultMap);

    return resultMap;
  }




  Future<void> appendExamStat(String key, Map<String, dynamic> data) async {
    final directory = await SdCardUtility.getBasePath();
    if (directory == null) return;

    final filePath = '$directory/exam_stats.json';
    final file = File(filePath);

    // Ensure directory exists
    await file.parent.create(recursive: true);


    Map<String, dynamic> existingData = {};
    if (await file.exists()) {
      try {
        existingData = jsonDecode(await file.readAsString());
      } catch (_) {}
    }

    // Add timestamp to data
    data['timestamp'] = DateTime.now().toIso8601String();

    // Append to list under the key
    final List<dynamic> previousAttempts = existingData[key] ?? [];
    previousAttempts.add(data);
    existingData[key] = previousAttempts;

    await file.writeAsString(jsonEncode(existingData));
    print("Appended stat under key: $key");
  }

  Future<List<Map<String, dynamic>>> readExamStatsList(String key) async {
    final directory = await SdCardUtility.getBasePath();
    if (directory == null) return[];

    final filePath = '$directory/exam_stats.json';
    final file = File(filePath);

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final allData = jsonDecode(content);
        final List<dynamic> entries = allData[key] ?? [];
        return entries.cast<Map<String, dynamic>>();
      } catch (e) {
        print("Error reading list: $e");
      }
    }

    return [];
  }


  Future<Map<String, List<Map<String, dynamic>>>> readAllExamStats() async {
    final directory = await SdCardUtility.getBasePath();
    if (directory == null) return{};

    final filePath = '$directory/exam_stats.json';
    final file = File(filePath);

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final Map<String, dynamic> rawData = jsonDecode(content);

        // Convert each key's value to List<Map<String, dynamic>>
        final result = <String, List<Map<String, dynamic>>>{};
        rawData.forEach((key, value) {
          result[key] = List<Map<String, dynamic>>.from(value);
        });

        return result;
      } catch (e) {
        print("Error reading all exam stats: $e");
      }
    }

    return {};
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
            titleCountMap.isEmpty
                ? const Center(child: Text("No attempts recorded."))
                : SizedBox(
              height: 250,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  itemCount: titleCountMap .length,
                  itemBuilder: (context, index) {
                    final entry = titleCountMap.entries.elementAt(index);
                    final title = entry.key;
                    final count = entry.value;

                    return _buildExamPerformance(title, count, "Simple");
                  },
                ),
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
    print("Attempts $attempts");
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              future: _getLatestStatFromFile('pcm'),
              builder: (context, snapshot) {
                print("Datatat------------- $snapshot.data");
                final data = snapshot.data ?? {
                  'attempts': 0,
                  'averageScore': 0,
                  'highestScore': 0,
                  'lowestScore': 0,
                  'currentLevel': 'Not started',
                };

                /*return _buildExamPerformanceTable(
                  'JEE (PCM)',
                  'Physics, Chemistry, Mathematics',
                  data,
                );*/

                return FutureBuilder<Map<String, Map<String, int>>>(
                  future: _getLevelAttemptsCount(),
                  builder: (context, levelSnapshot) {
                    final levelCounts = levelSnapshot.data ?? {
                      'pcm': {'Simple': 0, 'Medium': 0, 'Complex': 0, 'Difficult': 0, 'Advance': 0},
                      'pcb': {'Simple': 0, 'Medium': 0, 'Complex': 0, 'Difficult': 0, 'Advance': 0},
                    };

                    return _buildExamPerformanceTable(
                      'JEE (PCM)',
                      'Physics, Chemistry, Mathematics',
                      data,
                      levelCounts['pcm'] ?? {},
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // PCB Section (only show if PCB is enabled)
            if (showJEE)
              FutureBuilder<Map<String, dynamic>>(
                future: _getLatestStatFromFile('pcb'),
                builder: (context, snapshot) {
                  final data = snapshot.data ?? {
                    'attempts': 0,
                    'averageScore': 0,
                    'highestScore': 0,
                    'lowestScore': 0,
                    'currentLevel': 'Not started',
                  };

                  /*return _buildExamPerformanceTable(
                    'NEET (PCB)',
                    'Physics, Chemistry, Biology',
                    data,
                  );*/

                  return FutureBuilder<Map<String, Map<String, int>>>(
                    future: _getLevelAttemptsCount(),
                    builder: (context, levelSnapshot) {
                      final levelCounts = levelSnapshot.data ?? {
                        'pcm': {'Simple': 0, 'Medium': 0, 'Complex': 0, 'Difficult': 0, 'Advance': 0},
                        'pcb': {'Simple': 0, 'Medium': 0, 'Complex': 0, 'Difficult': 0, 'Advance': 0},
                      };

                      return _buildExamPerformanceTable(
                        'JEE (PCB)',
                        'Physics, Chemistry, Biology',
                        data,
                        levelCounts['pcb'] ?? {},
                      );
                    },
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



  Future<Map<String, dynamic>> _getLatestStatFromFile(String key) async {

    final directory = await SdCardUtility.getBasePath();
    if (directory == null) return _emptyStat();

    final filePath = '$directory/exam_stats.json';
    final file = File(filePath);

    if (!await file.exists()) return _emptyStat();

    try {
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      if (data[key] != null && data[key] is List && data[key].isNotEmpty) {
        final List attempts = data[key];
        return Map<String, dynamic>.from(attempts.last); // latest attempt
      }
    } catch (e) {
      print("Error reading $key stats: $e");
    }

    return _emptyStat();
  }

  Map<String, dynamic> _emptyStat() => {
    'attempts': 0,
    'averageScore': 0.0,
    'highestScore': 0.0,
    'lowestScore': 0.0,
    'currentLevel': 'Not started',
  };

  Future<Map<String, Map<String, int>>> _getLevelAttemptsCount() async {
    final directory = await SdCardUtility.getBasePath();
    if (directory == null) return {};

    final filePath = '$directory/jee_exam_attempt.json';
    final file = File(filePath);

    if (!await file.exists()) return {};

    try {
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      Map<String, Map<String, int>> levelCounts = {
        'pcm': {'Simple': 0, 'Medium': 0, 'Complex': 0, 'Difficult': 0, 'Advance': 0},
        'pcb': {'Simple': 0, 'Medium': 0, 'Complex': 0, 'Difficult': 0, 'Advance': 0},
      };

      data.forEach((key, value) {
        if (value is List) {
          for (var attempt in value) {
            if (attempt is Map<String, dynamic>) {
              final isPCB = attempt['isPCB'] == true;
              final stream = isPCB ? 'pcb' : 'pcm';
              final levelTag = attempt['level']?.toString().toLowerCase() ?? 's';

              String level;
              switch (levelTag) {
                case 's':
                  level = 'Simple';
                  break;
                case 'm':
                  level = 'Medium';
                  break;
                case 'c':
                  level = 'Complex';
                  break;
                case 'd':
                  level = 'Difficult';
                  break;
                case 'a':
                  level = 'Advance';
                  break;
                default:
                  level = 'Simple'; // Default to Simple if level tag is unknown
              }

              levelCounts[stream]?[level] = (levelCounts[stream]?[level] ?? 0) + 1;
            }
          }
        }
      });

      return levelCounts;
    } catch (e) {
      print('Error reading level attempts: $e');
      return {};
    }
  }

// Helper widget to build exam performance table
  Widget _buildExamPerformanceTable(String exam, String subjects, Map<String, dynamic> data, Map<String, int> levelCounts,) {

    print("Datatat $data");
    print("EXAMM $exam");
    // Convert all numeric values to double
    final attempts = (data['attempts'] as int);
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
        /*Map<String, int> levelCounts = {
          'Simple': currentLevel=="Simple" ? attempts: 0,
          'Medium': currentLevel=="Medium" ? attempts : 0,
          'Complex': currentLevel=="Complex" ?attempts : 0,
          'Difficult': 0,
          'Advance': 0,
        };*/


        //levelCounts = _getLevelAttemptsCount()  //[isPCB ?? 'pcb' : 'pcm']?? {};
        print("DATA MOCK ${snapshot.data}");
        // Count attempts per level if we have data
        /*if (snapshot.hasData && snapshot.data!.isNotEmpty) {
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
            levelCounts[level] = (levelCounts[level] ?? 0);
          }
        }*/

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
                      levelCounts[currentLevel]==null ? "0" : "${levelCounts[currentLevel]}",
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



    print("_moc ${_mockExamMap}");
    if (data != null) {
      try {
        final parsed = _mockExamMap;
        setState(() {
          print("MOCKKC ${_mockExamMap}");
          attemptCounts = parsed;
          isLoading = false;
        });
      } catch (_) {
        setState(() {
          attemptCounts = _mockExamMap;
         // attemptCounts = {};
          isLoading = false;
        });
      }
    } else {
      setState(() {
        attemptCounts = _mockExamMap;
       // attemptCounts = {};
        isLoading = false;
      });
    }
  }

  /// 1) Save all the data into study_tracker_data.json
  /// 2) Immediately re-open it and print counts to verify.
  Future<void> saveAllDataToMemoryCard() async {
    try {
      final directory = await SdCardUtility.getBasePath();
      final filePath = '$directory/study_tracker_data.json';
      final file = File(filePath);

      // 1) Read existing JSON (if any)
      Map<String, dynamic> existingData = {};
      if (await file.exists()) {
        final contents = await file.readAsString();
        existingData = jsonDecode(contents);
      }

      final String todayDate = DateTime.now()
          .toIso8601String()
          .substring(0, 10); // yyyy-MM-dd

      // 2) Build your new entries
      final newStudyTimeEntry = {
        "date": todayDate,
        "today": today.inSeconds,
        "yesterday": yesterday.inSeconds,
        "total": total.inSeconds,
        "average": average.inSeconds,
        "lowest": lowest.inSeconds,
        "highest": highest.inSeconds,
      };
      final newActivityCountsEntry = {
        "date": todayDate,
        "video_count": videoCount,
        "answer_count": answerCount,
      };

      // 3) Append to study_time_log
      final studyTimeLog = (existingData['study_time_log'] is List)
          ? List<dynamic>.from(existingData['study_time_log'])
          : <dynamic>[];
      studyTimeLog.add(newStudyTimeEntry);
      existingData['study_time_log'] = studyTimeLog;

      // 4) Append to activity_counts_log
      final activityCountsLog = (existingData['activity_counts_log'] is List)
          ? List<dynamic>.from(existingData['activity_counts_log'])
          : <dynamic>[];
      activityCountsLog.add(newActivityCountsEntry);
      existingData['activity_counts_log'] = activityCountsLog;

      // 5) Overwrite course_progress & target_dates
      existingData['course_progress'] = {
        'total_percentage': totalpercentageValue,
        'subjects': await _getAllSubjectProgressData(),
      };
      existingData['target_dates'] = _getTargetDatesData();

      // 6) Append mock_exams safely
      final existingMockExams = (existingData['mock_exams'] is List)
          ? List<dynamic>.from(existingData['mock_exams'])
          : <dynamic>[];
      final mockList = await _getMockExamData();
      for (var entry in mockList) {
        existingMockExams.add({
          'date': todayDate,
          ...entry, // chapter & attempts
        });
      }
      existingData['mock_exams'] = existingMockExams;

      // 7) Append competitive_exams safely
      final existingComp = (existingData['competitive_exams'] is List)
          ? List<dynamic>.from(existingData['competitive_exams'])
          : <dynamic>[];
      final compList = await _getCompetitiveExamData();
      for (var entry in compList) {
        existingComp.add({
          'date': todayDate,
          ...entry, // exam & stats
        });
      }
      existingData['competitive_exams'] = existingComp;

      // 8) Overwrite metadata
      existingData['metadata'] = {
        'last_updated': DateTime.now().toIso8601String(),
        'device_id': await _getDeviceId(),
      };

      // 9) Write back to file
      await file.writeAsString(jsonEncode(existingData));
      print('Data saved with historical logs to: $filePath');

      // 10) Debug: read it right back in and print sizes & snippets
      await _debugSavedData(filePath);
    } catch (e) {
      print('Error saving historical data: $e');
    }
  }

  /// Helper that re-opens your JSON log and prints out
  /// the length of each array and the raw maps for quick verification.
  Future<void> _debugSavedData(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      print('❌ Debug: file not found at $filePath');
      return;
    }

    final jsonString = await file.readAsString();
    dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (e) {
      print('❌ Debug: could not parse JSON: $e');
      return;
    }

    print('=== DEBUG: Loaded JSON ===');
    if (decoded is Map<String, dynamic>) {
      final data = decoded;
      print(' • study_time_log entries: ${_safeLength(data['study_time_log'])}');
      print(' • activity_counts_log entries: ${_safeLength(data['activity_counts_log'])}');
      print(' • mock_exams entries: ${_safeLength(data['mock_exams'])}');
      print(' • competitive_exams entries: ${(data['competitive_exams'])}');
      print(' • course_progress: ${data['course_progress']}');
      print(' • target_dates: ${data['target_dates']}');
      print(' • metadata: ${data['metadata']}');
    } else if (decoded is List) {
      print(' • Top level is a List of length ${decoded.length}');
    } else {
      print(' • Unexpected top-level JSON type: ${decoded.runtimeType}');
    }
  }






  /// Safe helper: returns .length if it’s a List, else 0.
  int _safeLength(dynamic maybeList) {
    return maybeList is List ? maybeList.length : 0;
  }





// Helper methods for data preparation
  Future<List<Map<String, dynamic>>> _getAllSubjectProgressData() async {
    final subjectPercentages = await getAllSubjectPercentages();
    return subjectPercentages.entries.map((entry) {
      return {
        'subject': entry.key,
        'percentage': entry.value,
      };
    }).toList();
  }

  Map<String, dynamic> _getTargetDatesData() {
    Map<String, dynamic> data = {};
    for (int i = 0; i < subjects.length; i++) {
      final subject = subjects[i];
      final date = targetDate[i];
      data[subject] = date == "null" ? null : date;
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> _getMockExamData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('mock_attempt_counts') ?? '{}';
    final decoded = jsonDecode(jsonString);

    print("Decoded Mock $decoded");

    if (decoded is Map<String, dynamic>) {
      return decoded.entries.map((e) {
        final value = e.value;
        final count = (value is Map && value['count'] is int) ? value['count'] : 0;
        final std = (value is Map && value['std'] is int) ? value['std'] : 0;

        return {
          'chapter': e.key,
          'count': count,
          'std': std,
        };
      }).toList();
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getCompetitiveExamData() async {
    final pcmStats = await _calculateExamStats(false);
    final pcbStats = await _calculateExamStats(true);

    return [
      {
        'exam': 'pcm',
        'stats': pcmStats,
      },
      {
        'exam': 'pcb',
        'stats': pcbStats,
      },
    ];
  }

  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown-ios-device';
    }
    return 'unknown-device';
  }

  Future<void> loadDataFromMemoryCard() async {
    var mockStd;
    if(stdClass.contains('12')){
      mockStd = 12;
    }else if(stdClass.contains('10')){
      mockStd =10;
    }


    try {
      final directory = await SdCardUtility.getBasePath();
      final filePath = '$directory/study_tracker_data.json';
      final File file = File(filePath);

      if (!await file.exists()) {
        print('❌ No saved data file found at: $filePath');
        return;
      }

      final String jsonString = await file.readAsString();
      final dynamic decoded = jsonDecode(jsonString);

      // 1) Normalize to a Map<String, dynamic>
      late Map<String, dynamic> data;
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      } else if (decoded is List) {
        // old bug: top-level was a List, so wrap it as study_time_log
        data = {
          'study_time_log': decoded,
          'activity_counts_log': <dynamic>[],
          'mock_exams': <dynamic>[],
          'competitive_exams': <dynamic>[],
          'course_progress': <String, dynamic>{},
          'target_dates': <String, dynamic>{},
          'metadata': <String, dynamic>{},
        };
        print('⚠️ Wrapped top-level List as study_time_log');
      } else {
        print('❗ Unexpected JSON structure, aborting load.');
        return;
      }

      // 2) Safely extract each part, casting Lists where needed:
      final List<Map<String, dynamic>> studyLog =
          (data['study_time_log'] as List?)
              ?.cast<Map<String, dynamic>>() ??
              [];

      final List<Map<String, dynamic>> activityLog =
          (data['activity_counts_log'] as List?)
              ?.cast<Map<String, dynamic>>() ??
              [];


      print("Board Exam ${data['mock_exams']}");
      final List<Map<String, dynamic>> mockExams =
          (data['mock_exams'] as List?)
              ?.cast<Map<String, dynamic>>() ??
              [];



      final List<Map<String, dynamic>> competitiveExams =
          (data['competitive_exams'] as List?)
              ?.cast<Map<String, dynamic>>() ??
              [];

      final Map<String, dynamic> courseProgress =
          (data['course_progress'] as Map?)?.cast<String, dynamic>() ??
              {};

      final Map<String, dynamic> targetDates =
          (data['target_dates'] as Map?)?.cast<String, dynamic>() ??
              {};

      final Map<String, dynamic> metadata =
          (data['metadata'] as Map?)?.cast<String, dynamic>() ??
              {};

      final Map<String, int> newAttemptCounts = {
        for (var exam in mockExams)
          exam['chapter'] as String:
          (exam['count'] is int
              ? exam['count'] as int
              : int.tryParse(exam['count'].toString()) ?? 0)
      };



      final Map<String, Map<String, dynamic>> chapterData = {
        for (var exam in mockExams)
          exam['chapter'] as String: {
            'count': (exam['count'] is int
                ? exam['count'] as int
                : int.tryParse(exam['count'].toString()) ?? 0),
            'std': (exam['std'] is int
                ? exam['std'] as int
                : int.tryParse(exam['std'].toString()) ?? 0),
            'date': exam['date']?.toString() ?? '',
          }
      };



      print("Mock Stdd $mockStd");
      final filteredChapterData = chapterData.entries
          .where((entry) => entry.value['std'] == mockStd)
          .toList();


      final Map<String, int> newAttemptCountsStd12 = {
        for (var entry in filteredChapterData)
          entry.key: entry.value['count'] ?? 0
      };





      // 3) Pull out “last” entries safely:
      final lastStudy = studyLog.isNotEmpty ? studyLog.last : {};
      final lastActivity = activityLog.isNotEmpty ? activityLog.last : {};

      setState(() {
        today = Duration(seconds: lastStudy['today'] ?? 0);
        yesterday = Duration(seconds: lastStudy['yesterday'] ?? 0);
        total = Duration(seconds: lastStudy['total'] ?? 0);
        average = Duration(seconds: lastStudy['average'] ?? 0);
        lowest = Duration(seconds: lastStudy['lowest'] ?? 0);
        highest = Duration(seconds: lastStudy['highest'] ?? 0);

        videoCount = lastActivity['video_count'] ?? 0;
        answerCount = lastActivity['answer_count'] ?? 0;

        totalpercentageValue =
            courseProgress['total_percentage']?.toString() ?? "0.0";

        _targetDateMap = targetDates;
        _mockExamMap = mockExams.isNotEmpty ? mockExams.last : {};
        _competitiveExamMap =
        competitiveExams.isNotEmpty ? competitiveExams.last : {};
        _metadata = metadata;
       // attemptCounts = newAttemptCounts;
        attemptCounts = newAttemptCountsStd12;
      });

      print("Mock Exam ${_mockExamMap}");

      print("✔️ All data loaded from: $filePath");
    } catch (e) {
      print('❗ Error loading data: $e');
    }
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

          print("CourseList $courseList");

          List<String> allowedClasses = courseList
              .map((course) {
            if (course.contains("10")) return "10";
            if (course.contains("12")) return "12";
            if (course.contains("JEE")) return "JEE";
            return "";
          })
              .where((cls) => cls.isNotEmpty)
              .toList();

          // Filter based on courseList
          final filtered = loadedSubmissions.where((sub) {
            final stream = sub["questions"][0]["stream"]?.toString() ?? '';
            return allowedClasses.contains(stream);
          }).toList();

          // 🔁 Count all titles
          Map<String, int> titleCounts = {};
          for (var item in filtered) {
            String title = item["title"] ?? "Unknown Title";
            titleCounts[title] = (titleCounts[title] ?? 0) + 1;
          }

          print("Filtered Submissions: $filtered");
          print("Title Counts: $titleCounts");

          setState(() {
            submissions = filtered;
            titleCountMap = titleCounts; // <-- define this as Map<String, int>
          });

        } else {
          print('File content is not a List');
          setState(() {
            submissions = [];
            titleCountMap = {};
          });
        }

      } else {
        print('mock_exam.json not found');
        setState(() {
          submissions = [];
          titleCountMap = {};
        });
      }
    } catch (e) {
      print('Error loading submissions: $e');
      setState(() {
        submissions = [];
        titleCountMap = {};
      });
    }
  }



}