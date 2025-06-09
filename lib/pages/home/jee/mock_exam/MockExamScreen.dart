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
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:sigma_new/models/sub_cahp_datum.dart';

import '../../../../math_view/math_text_test.dart' show MathTextTest;
import '../../../../ui_helper/constant.dart';

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

    final hasSavedState = await _loadExamState();

    // If no saved state, shuffle questions normally
    if (!hasSavedState && questions.isNotEmpty) {
      setState(() {
        questions.shuffle();
        selectedAnswers = List.filled(questions.length, '');
      });
    }

    // Start timer if needed
    if (!timerStarted && questions.isNotEmpty) {
      examStartTime = DateTime.now();
      _startTimer();
      timerStarted = true;
    }
  }


  Future<void> _saveExamState() async {
    final questionsJson = questions.map((q) => q.toJson()).toList();

    await prefs.setInt('mock_exam_current_index', currentIndex);
    await prefs.setInt('mock_exam_correct', correct);
    await prefs.setInt('mock_exam_wrong', wrong);
    await prefs.setStringList('mock_exam_selected_answers', selectedAnswers);
    await prefs.setString('mock_exam_subject_id', widget.subjectId);
    await prefs.setString('mock_exam_title', widget.title);
    await prefs.setString('mock_exam_path', widget.path);
    await prefs.setInt('mock_exam_remaining_time', duration.inSeconds);
    await prefs.setString('mock_exam_start_time', examStartTime?.toIso8601String() ?? '');

    // Save the shuffled questions list as JSON
    await prefs.setString('mock_exam_questions', jsonEncode(questionsJson));
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
        questionList;

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
      questions;
      //questions.shuffle();
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
  void dispose() {
    countdownTimer?.cancel();
    _clearSavedExamState(); // Add this line
    super.dispose();
  }

  Future<void> _clearSavedExamState() async {
    await prefs.remove('mock_exam_current_index');
    await prefs.remove('mock_exam_correct');
    await prefs.remove('mock_exam_wrong');
    await prefs.remove('mock_exam_selected_answers');
    await prefs.remove('mock_exam_subject_id');
    await prefs.remove('mock_exam_title');
    await prefs.remove('mock_exam_path');
    await prefs.remove('mock_exam_remaining_time');
    await prefs.remove('mock_exam_start_time');
    await prefs.remove('mock_exam_questions'); // Clear saved questions
  }

  //Pause Test
  Future<bool> _loadExamState() async {
    final savedSubjectId = prefs.getString('mock_exam_subject_id');
    if (savedSubjectId == null || savedSubjectId != widget.subjectId) {
      return false; // No saved state for this subject
    }

    // Restore the shuffled questions list
    final questionsJson = prefs.getString('mock_exam_questions');
    if (questionsJson != null) {
      final decoded = jsonDecode(questionsJson) as List<dynamic>;
      setState(() {
        questions = decoded.map((e) => SubCahpDatum.fromJson(e)).toList();
      });
    }

    setState(() {
      currentIndex = prefs.getInt('mock_exam_current_index') ?? 0;
      correct = prefs.getInt('mock_exam_correct') ?? 0;
      wrong = prefs.getInt('mock_exam_wrong') ?? 0;
      selectedAnswers = prefs.getStringList('mock_exam_selected_answers') ?? List.filled(questions.length, '');

      final remainingTime = prefs.getInt('mock_exam_remaining_time') ?? 7200;
      duration = Duration(seconds: remainingTime);

      final startTimeStr = prefs.getString('mock_exam_start_time');
      if (startTimeStr != null && startTimeStr.isNotEmpty) {
        examStartTime = DateTime.parse(startTimeStr);
      }

      timerStarted = true;
    });

    // Clear the saved state (optional, can keep until exam is completed)
    await _clearSavedExamState(); // Or remove only after exam completion
    return true;
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
        bottomNavigationBar:InkWell(
          onTap: () async {
            countdownTimer?.cancel();
            await _saveExamState();
            Get.back();
            // Optionally show a confirmation message
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test paused. You can resume where you left off.'))
            );
           // Get.to(LastMinuteRevision(path: widget.path,));
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                color: redColor,
                boxShadow:const [
                  BoxShadow(
                    color: whiteColor,
                  )
                ],
                borderRadius: BorderRadius.circular(10)
            ),
            height: 60,
            alignment: Alignment.center,
            child: const Text('Pause Test', style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),),
          ),
        ),
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
                return Container(

                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                  ),
                  child: ListTile(
                    title: MathText(expression: opt, height: estimateHeight(opt),),
                    leading: Radio<String>(
                      value: opt,
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                  ),
                );
              }),
              Center(
                child: InkWell(
                  onTap: selectedOption != null ? () => _submitAnswer(selectedOption!) : null,
                  child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      width: Get.width,
                      decoration: BoxDecoration(
                          color: primaryColor,
                          boxShadow:const [
                            BoxShadow(
                              color: whiteColor,
                            )
                          ],
                          borderRadius: BorderRadius.circular(10)
                      ),
                      height: 60,
                      alignment: Alignment.center,
                      child: const Text("Submit Answer", style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold))),
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