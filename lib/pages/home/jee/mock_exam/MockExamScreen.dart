/*
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:sigma_new/models/sub_cahp_datum.dart';

class MockExamScreen extends StatefulWidget {
  final String subjectId;
  final String title;
  final String path;

  const MockExamScreen({
    super.key,
    required this.subjectId,
    required this.title,
    required this.path,
  });

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  late SharedPreferences prefs;

  int currentIndex = 0;
  List<SubCahpDatum> questions = [];
  List<String> selectedAnswers = [];

  final int SUB1_Q_COUNT = 98;
  final int SUB2_Q_COUNT = 52;
  final int SUB3_Q_COUNT = 50;

  final String MAT_FILE_PREFIX = "jeemcqmathch";
  final String PHY_FILE_PREFIX = "jeemcqphych";
  final String CHE_FILE_PREFIX = "jeemcqchech";

  int totalQueCount = 0;

  int correct = 0;
  int wrong = 0;

  Timer? countdownTimer;
  Duration duration = const Duration(minutes: 120);
  bool timerStarted = false;

  String? selectedOption;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    prefs = await SharedPreferences.getInstance();
    await _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    totalQueCount = SUB1_Q_COUNT + SUB2_Q_COUNT + SUB3_Q_COUNT;

    List<Uri> mathsFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", MAT_FILE_PREFIX) ?? [];
    List<Uri> phyFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", PHY_FILE_PREFIX) ?? [];
    List<Uri> cheFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", CHE_FILE_PREFIX) ?? [];

    final mathUri = FileUri(
      files: mathsFiles,
      perChapterCount: mathsFiles.isNotEmpty ? SUB1_Q_COUNT ~/ mathsFiles.length : 0,
      remainCount: mathsFiles.isNotEmpty ? SUB1_Q_COUNT % mathsFiles.length : 0,
    );

    final phyUri = FileUri(
      files: phyFiles,
      perChapterCount: phyFiles.isNotEmpty ? SUB2_Q_COUNT ~/ phyFiles.length : 0,
      remainCount: phyFiles.isNotEmpty ? SUB2_Q_COUNT % phyFiles.length : 0,
    );

    final cheUri = FileUri(
      files: cheFiles,
      perChapterCount: cheFiles.isNotEmpty ? SUB3_Q_COUNT ~/ cheFiles.length : 0,
      remainCount: cheFiles.isNotEmpty ? SUB3_Q_COUNT % cheFiles.length : 0,
    );

    Future<void> processFiles(FileUri uriGroup) async {
      for (int i = 0; i < uriGroup.files.length; i++) {
        final file = uriGroup.files[i];
        final jsonStr = await SdCardUtility.getSubjectEncJsonDataForMock(file.path);
        if (jsonStr == null) continue;

        final decoded = jsonDecode(jsonStr);
        if (decoded == null || decoded['sigma_data'] == null) continue;

        final sigmaList = decoded['sigma_data'] as List<dynamic>;
        final questionList = sigmaList.map((e) => SubCahpDatum.fromJson(e)).toList();
        questionList.shuffle();

        int takeCount = uriGroup.perChapterCount + (i < uriGroup.remainCount ? 1 : 0);
        final selected = questionList.take(takeCount).toList();

        setState(() {
          questions.addAll(selected);
          selectedAnswers.addAll(List.filled(selected.length, ''));
          if (!timerStarted && questions.isNotEmpty) {
            _startTimer();
            timerStarted = true;
          }
        });
      }
    }

    await Future.wait([
      processFiles(mathUri),
      processFiles(phyUri),
      processFiles(cheUri),
    ]);

    setState(() {
      questions.shuffle();
    });

    print("Total questions loaded: ${questions.length}");
  }

  void _startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (duration.inSeconds == 0) {
        timer.cancel();
        _showResultPopup();
      } else {
        setState(() {
          duration -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _submitAnswer(String answer) {
    if (questions.isEmpty) return;

    final current = questions[currentIndex];
    selectedAnswers[currentIndex] = answer;

    if (answer.trim() == current.answer?.trim()) {
      correct++;
    } else {
      wrong++;
    }

    if (currentIndex + 1 < questions.length) {
      setState(() {
        currentIndex++;
        selectedOption = null;
      });
    } else {
      countdownTimer?.cancel();
      _showResultPopup();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Time Left: ${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Question ${currentIndex + 1} of ${questions.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MathText(
                  expression: question.question ?? '',
                  height: estimateHeight(question.question ?? ''),
                ),
              ),
              ...List.generate(4, (index) {
                final opt = question.toJson()['option_${index + 1}'];
                if (opt == null || opt.toString().trim().isEmpty) return const SizedBox();
                return ListTile(
                  title: MathText(expression: opt, height: estimateHeight(opt)),
                  leading: Radio<String>(
                    value: opt,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                );
              }),
              Center(
                child: ElevatedButton(
                  onPressed: selectedOption != null ? () => _submitAnswer(selectedOption!) : null,
                  child: const Text("Submit Answer"),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showResultPopup() async {
    final total = prefs.getInt('test_complete') ?? 0;
    final high = prefs.getInt('test_high_score') ?? 0;
    final totalScore = prefs.getInt('test_total_score') ?? 0;

    prefs.setInt('test_complete', total + 1);
    prefs.setInt('test_total_score', totalScore + correct);
    if (correct > high) prefs.setInt('test_high_score', correct);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Test Completed"),
        content: Text("Correct: $correct\nWrong: $wrong"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  double estimateHeight(String text) {
    final lines = (text.length / 30).ceil(); // assume 30 chars per line
    return lines * 35.0; // assume each line is about 35 pixels tall
  }
}

class FileUri {
  final List<Uri> files;
  final int perChapterCount;
  final int remainCount;

  FileUri({
    required this.files,
    required this.perChapterCount,
    required this.remainCount,
  });
}
*/



import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:sigma_new/models/sub_cahp_datum.dart';

class MockExamScreen extends StatefulWidget {
  final String subjectId;
  final String title;
  final String path;

  const MockExamScreen({
    super.key,
    required this.subjectId,
    required this.title,
    required this.path,
  });

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  late SharedPreferences prefs;

  int currentIndex = 0;
  List<SubCahpDatum> questions = [];
  List<String> selectedAnswers = [];

  final int SUB1_Q_COUNT = 98;
  final int SUB2_Q_COUNT = 52;
  final int SUB3_Q_COUNT = 50;

  final String MAT_FILE_PREFIX = "jeemcqmathch";
  final String PHY_FILE_PREFIX = "jeemcqphych";
  final String CHE_FILE_PREFIX = "jeemcqchech";

  int totalQueCount = 0;

  int correct = 0;
  int wrong = 0;

  Timer? countdownTimer;
  Duration duration = const Duration(minutes: 120);
  bool timerStarted = false;

  String? selectedOption;
  DateTime? examStartTime;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    prefs = await SharedPreferences.getInstance();
    await _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    totalQueCount = SUB1_Q_COUNT + SUB2_Q_COUNT + SUB3_Q_COUNT;

    List<Uri> mathsFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", MAT_FILE_PREFIX) ?? [];
    List<Uri> phyFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", PHY_FILE_PREFIX) ?? [];
    List<Uri> cheFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", CHE_FILE_PREFIX) ?? [];

    final mathUri = FileUri(
      files: mathsFiles,
      perChapterCount: mathsFiles.isNotEmpty ? SUB1_Q_COUNT ~/ mathsFiles.length : 0,
      remainCount: mathsFiles.isNotEmpty ? SUB1_Q_COUNT % mathsFiles.length : 0,
    );

    final phyUri = FileUri(
      files: phyFiles,
      perChapterCount: phyFiles.isNotEmpty ? SUB2_Q_COUNT ~/ phyFiles.length : 0,
      remainCount: phyFiles.isNotEmpty ? SUB2_Q_COUNT % phyFiles.length : 0,
    );

    final cheUri = FileUri(
      files: cheFiles,
      perChapterCount: cheFiles.isNotEmpty ? SUB3_Q_COUNT ~/ cheFiles.length : 0,
      remainCount: cheFiles.isNotEmpty ? SUB3_Q_COUNT % cheFiles.length : 0,
    );

    Future<void> processFiles(FileUri uriGroup) async {
      for (int i = 0; i < uriGroup.files.length; i++) {
        final file = uriGroup.files[i];
        final jsonStr = await SdCardUtility.getSubjectEncJsonDataForMock(file.path);
        if (jsonStr == null) continue;

        final decoded = jsonDecode(jsonStr);
        if (decoded == null || decoded['sigma_data'] == null) continue;

        final sigmaList = decoded['sigma_data'] as List<dynamic>;
        final questionList = sigmaList.map((e) => SubCahpDatum.fromJson(e)).toList();
        questionList.shuffle();

        int takeCount = uriGroup.perChapterCount + (i < uriGroup.remainCount ? 1 : 0);
        final selected = questionList.take(takeCount).toList();

        setState(() {
          questions.addAll(selected);
          selectedAnswers.addAll(List.filled(selected.length, ''));
          if (!timerStarted && questions.isNotEmpty) {
            examStartTime = DateTime.now();
            _startTimer();
            timerStarted = true;
          }
        });
      }
    }

    await Future.wait([
      processFiles(mathUri),
      processFiles(phyUri),
      processFiles(cheUri),
    ]);

    setState(() {
      questions.shuffle();
    });

    print("Total questions loaded: ${questions.length}");
  }

  void _startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (duration.inSeconds == 0) {
        timer.cancel();
        _showResultPopup();
      } else {
        setState(() {
          duration -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _submitAnswer(String answer) {
    if (questions.isEmpty) return;

    final current = questions[currentIndex];
    selectedAnswers[currentIndex] = answer;

    if (answer.trim() == current.answer?.trim()) {
      correct++;
    } else {
      wrong++;
    }

    if (currentIndex + 1 < questions.length) {
      setState(() {
        currentIndex++;
        selectedOption = null;
      });
    } else {
      countdownTimer?.cancel();
      _showResultPopup();
    }
  }

  Future<void> _saveExamResult() async {
    // Get or initialize exam attempts list
    final examAttemptsJson = prefs.getString('mock_exam_attempts') ?? '[]';
    final List<dynamic> examAttempts = jsonDecode(examAttemptsJson);

    // Create new exam result
    final examResult = {
      'title': widget.title,
      'date': examStartTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'duration': (120 - duration.inMinutes).toString(),
      'correct': correct,
      'wrong': wrong,
      'total': questions.length,
      'subjectId': widget.subjectId,
    };

    // Add new attempt to the list
    examAttempts.add(examResult);

    print("EXAMATTEPSTT $examAttempts");
    // Save updated list
    await prefs.setString('mock_exam_attempts', jsonEncode(examAttempts));

    // Update general stats
    final totalAttempts = prefs.getInt('total_mock_exam_attempts') ?? 0;
    await prefs.setInt('total_mock_exam_attempts', totalAttempts + 1);

    // Update high score if needed
    final highScore = prefs.getInt('mock_exam_high_score') ?? 0;
    if (correct > highScore) {
      await prefs.setInt('mock_exam_high_score', correct);
    }

    // Update subject-specific stats
    final subjectKey = 'mock_exam_stats_${widget.subjectId}';
    final subjectStatsJson = prefs.getString(subjectKey) ?? '{"attempts": 0, "high_score": 0}';
    final subjectStats = jsonDecode(subjectStatsJson);
    subjectStats['attempts'] = (subjectStats['attempts'] as int) + 1;
    if (correct > (subjectStats['high_score'] as int)) {
      subjectStats['high_score'] = correct;
    }

    print("SubjectKeyy"+subjectKey);
    await prefs.setString(subjectKey, jsonEncode(subjectStats));
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Time Left: ${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Question ${currentIndex + 1} of ${questions.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MathText(
                  expression: question.question ?? '',
                  height: estimateHeight(question.question ?? ''),
                ),
              ),
              ...List.generate(4, (index) {
                final opt = question.toJson()['option_${index + 1}'];
                if (opt == null || opt.toString().trim().isEmpty) return const SizedBox();
                return ListTile(
                  title: MathText(expression: opt, height: estimateHeight(opt)),
                  leading: Radio<String>(
                    value: opt,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                );
              }),
              Center(
                child: ElevatedButton(
                  onPressed: selectedOption != null ? () => _submitAnswer(selectedOption!) : null,
                  child: const Text("Submit Answer"),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showResultPopup() async {
    // Save the exam result first
    await _saveExamResult();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Test Completed"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title: ${widget.title}"),
            Text("Date: ${examStartTime?.toLocal().toString() ?? 'Unknown'}"),
            Text("Correct: $correct"),
            Text("Wrong: $wrong"),
            Text("Total Questions: ${questions.length}"),
            Text("Score: ${(correct / questions.length * 100).toStringAsFixed(1)}%"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  double estimateHeight(String text) {
    final lines = (text.length / 30).ceil();
    return lines * 35.0;
  }
}

class FileUri {
  final List<Uri> files;
  final int perChapterCount;
  final int remainCount;

  FileUri({
    required this.files,
    required this.perChapterCount,
    required this.remainCount,
  });
}