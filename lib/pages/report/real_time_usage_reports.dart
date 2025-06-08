import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';



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

  int videoCount = 0;
  int answerCount = 0;
  List<String> courseList=[];
  bool showJEE=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUsageData();
    printTotalPercentage();
    sharePreferenceData();
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
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (double.tryParse(totalpercentageValue))!/100,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text('Overall: ${totalpercentageValue.toString()}% (Pending ${100-double.parse(totalpercentageValue)}%)', style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16
            ),),
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
            const Text(
              'Target Completion Dates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              height: 150,
              child: FutureBuilder<Map<String, double>>(
                future: getAllSubjectPercentages(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final subject = snapshot.data!.keys.elementAt(index);
                      final percentage = snapshot.data![subject]!;

                      return _buildSubjectTarget(subject, 'Oct 31, 2025', percentage );

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
            _buildExamPerformance('Mathematics', 0, 'Simple'),
            _buildExamPerformance('Physics', 0, 'Simple'),
            _buildExamPerformance('Chemistry', 0, 'Simple'),
            _buildExamPerformance('Biology', 0, 'Simple'),
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
          Text(subject),
          Row(
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
            _buildCompetitiveExam('JEE', 'PCM'),
            _buildCompetitiveExam('CET', 'PCM/PCB'),
            _buildCompetitiveExam('NEET', 'PCB'),
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

  Widget _buildCompetitiveExam(String exam, String subjects) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
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
          Container(
            child: Row(
              children: [
                Expanded(flex: 2,child: Text('Present Level', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex:2,child: Text('Attempted', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex:2,child: Text('Average Score', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex:2,child: Text('Lowest Score', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex:2,child: Text('Highest Score', style: TextStyle(fontWeight: FontWeight.bold))),
               // Expanded(flex:2,child: Text('Performance', style: TextStyle(fontWeight: FontWeight.bold)))
              ],
            ),
          ),
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
                    child: Text('Simple', style: TextStyle(fontWeight: FontWeight.bold,))),
                Expanded(
                    flex: 2,
                    child: Text('0', style: TextStyle(fontWeight: FontWeight.bold))), // Example data
                Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Avg: 0%', style: TextStyle( // Example data
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        )), // Example data
                        // Example data
                      ],
                    )),
                Expanded(
                    flex: 2,
                    child: Text('Low: 0%', style: TextStyle( // Example data
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ))),
                Expanded(
                    flex: 2,
                    child: Text('High: 0%', style: TextStyle( // Example data
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ))),

              ],
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 1; i <= 5; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text('Level $i: Not attempted yet'),
            ),
          const Text('Present Status: Not started'),
          const Divider(),
        ],
      ),
    );
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
}