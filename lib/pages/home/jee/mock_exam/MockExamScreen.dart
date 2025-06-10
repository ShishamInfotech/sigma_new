import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:sigma_new/models/sub_cahp_datum.dart';

import '../../../../ui_helper/constant.dart';

class MockExamScreen extends StatefulWidget {
  final String subjectId;
  final String title;
  final String path;
  final bool isPCB; // Add this to distinguish between PCM and PCB

  const MockExamScreen({
    super.key,
    required this.subjectId,
    required this.title,
    required this.path,
    required this.isPCB,
  });

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  late SharedPreferences prefs;

  int currentIndex = 0;
  List<SubCahpDatum> questions = [];
  List<String> selectedAnswers = [];

  // Updated question counts based on instructions
  final int PHYSICS_Q_COUNT = 52;
  final int CHEMISTRY_Q_COUNT = 50;
  final int MATH_Q_COUNT = 98;
  final int BIOLOGY_Q_COUNT = 98;

  final String MAT_FILE_PREFIX = "jeemcqmathch";
  final String PHY_FILE_PREFIX = "jeemcqphych";
  final String CHE_FILE_PREFIX = "jeemcqchech";
  final String BIO_FILE_PREFIX = "jeemcqbioch"; // Add biology file prefix

  int totalQueCount = 0;

  int correct = 0;
  int wrong = 0;

  Timer? countdownTimer;
  Duration duration = const Duration(minutes: 120);
  bool timerStarted = false;

  String? selectedOption;
  DateTime? examStartTime;
  bool isLoadingFirstQuestion = true;

  @override
  void initState() {
    super.initState();
    _initialize();
    _setExamDuration();
  }

  Future<void> _initialize() async {
    prefs = await SharedPreferences.getInstance();
    final hasSavedState = await _loadExamState();

    if (!hasSavedState) {
      // Start loading first subject immediately
      _loadFirstSubjectQuestions().then((firstQuestions) {
        if (firstQuestions.isNotEmpty) {
          setState(() {
            questions.addAll(firstQuestions);
            selectedAnswers = List.filled(questions.length, '');
            isLoadingFirstQuestion = false;
          });

          // Start timer when first questions are loaded
          if (!timerStarted && questions.isNotEmpty) {
            examStartTime = DateTime.now();
            _startTimer();
            timerStarted = true;
          }
        }
      });

      // Load remaining subjects in background
      _loadRemainingQuestions();
    }
  }

  Future<List<SubCahpDatum>> _loadFirstSubjectQuestions() async {
    // Load Physics first (common for both PCM and PCB)
    final phyFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", PHY_FILE_PREFIX) ?? [];

    if (phyFiles.isEmpty) return [];

    final phyUri = FileUri(
      files: phyFiles,
      perChapterCount: phyFiles.isNotEmpty ? PHYSICS_Q_COUNT ~/ phyFiles.length : 0,
      remainCount: phyFiles.isNotEmpty ? PHYSICS_Q_COUNT % phyFiles.length : 0,
    );

    List<SubCahpDatum> physicsQuestions = [];
    await _processFiles(phyUri, physicsQuestions, "Physics");

    return physicsQuestions;
  }

  Future<void> _loadRemainingQuestions() async {
    // Load Chemistry
    final cheFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", CHE_FILE_PREFIX) ?? [];
    final cheUri = FileUri(
      files: cheFiles,
      perChapterCount: cheFiles.isNotEmpty ? CHEMISTRY_Q_COUNT ~/ cheFiles.length : 0,
      remainCount: cheFiles.isNotEmpty ? CHEMISTRY_Q_COUNT % cheFiles.length : 0,
    );

    List<SubCahpDatum> chemistryQuestions = [];
    await _processFiles(cheUri, chemistryQuestions, "Chemistry");
    print("Chemistry="+ chemistryQuestions.length.toString());
    // Load Math or Biology based on PCB flag
    if (widget.isPCB) {
      final bioFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", BIO_FILE_PREFIX) ?? [];
      final bioUri = FileUri(
        files: bioFiles,
        perChapterCount: bioFiles.isNotEmpty ? BIOLOGY_Q_COUNT ~/ bioFiles.length : 0,
        remainCount: bioFiles.isNotEmpty ? BIOLOGY_Q_COUNT % bioFiles.length : 0,
      );

      List<SubCahpDatum> biologyQuestions = [];
      await _processFiles(bioUri, biologyQuestions, "Biology");

      setState(() {
        questions.addAll(chemistryQuestions);
        print("Chemistry=================="+ chemistryQuestions.length.toString());
        questions.addAll(biologyQuestions);
        print("Biology==================="+ biologyQuestions.length.toString());
        selectedAnswers = List.filled(questions.length, '');
      });
    } else {
      final mathFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", MAT_FILE_PREFIX) ?? [];
      final mathUri = FileUri(
        files: mathFiles,
        perChapterCount: mathFiles.isNotEmpty ? MATH_Q_COUNT ~/ mathFiles.length : 0,
        remainCount: mathFiles.isNotEmpty ? MATH_Q_COUNT % mathFiles.length : 0,
      );

      List<SubCahpDatum> mathQuestions = [];
      await _processFiles(mathUri, mathQuestions, "Math");

      setState(() {
        questions.addAll(chemistryQuestions);
        questions.addAll(mathQuestions);
        selectedAnswers = List.filled(questions.length, '');
      });
    }

    // Shuffle all questions except the first few that are already being displayed
    if (questions.length > 10) {
      final firstQuestions = questions.sublist(0, 10);
      final remainingQuestions = questions.sublist(10);
      remainingQuestions.shuffle();

      setState(() {
        questions = firstQuestions + remainingQuestions;
      });
    }
  }

  // Add this property to track the current level
  String currentLevel = 's'; // Default to simple level

  // Modify the _processFiles method to filter by complexity
  Future<void> _processFiles(FileUri uriGroup, List<SubCahpDatum> targetList, String subject) async {
    for (int i = 0; i < uriGroup.files.length; i++) {
      final file = uriGroup.files[i];
      final jsonStr = await SdCardUtility.getSubjectEncJsonDataForMock(file.path);
      if (jsonStr == null) continue;

      final decoded = jsonDecode(jsonStr);
      if (decoded == null || decoded['sigma_data'] == null) continue;

      final sigmaList = decoded['sigma_data'] as List<dynamic>;
      final allQuestions = sigmaList.map((e) => SubCahpDatum.fromJson(e)).toList();

      // Filter questions based on current level
      List<SubCahpDatum> filteredQuestions = _filterQuestionsByComplexity(allQuestions);

      int takeCount = uriGroup.perChapterCount + (i < uriGroup.remainCount ? 1 : 0);
      targetList.addAll(filteredQuestions.take(takeCount));

      targetList.shuffle();
    }
  }

  // New method to filter questions by complexity
  List<SubCahpDatum> _filterQuestionsByComplexity(List<SubCahpDatum> allQuestions) {
    switch (currentLevel) {
      case 's': // Simple - 100% simple
        return allQuestions.where((q) => q.complexity == QuestionComplexity.simple).toList();
      case 'm': // Medium - 40% simple, 60% medium
        final simple = allQuestions.where((q) => q.complexity == QuestionComplexity.simple).toList();
        final medium = allQuestions.where((q) => q.complexity == QuestionComplexity.medium).toList();
        return [...simple.take((simple.length * 0.4).round()), ...medium];
      case 'c': // Complex - 40% medium, 60% complex
        final medium = allQuestions.where((q) => q.complexity == QuestionComplexity.medium).toList();
        final complex = allQuestions.where((q) => q.complexity == QuestionComplexity.complex).toList();
        return [...medium.take((medium.length * 0.4).round()), ...complex];
      case 'd': // Difficult - 50% complex, 50% difficult
        final complex = allQuestions.where((q) => q.complexity == QuestionComplexity.complex).toList();
        final difficult = allQuestions.where((q) => q.complexity == QuestionComplexity.difficult).toList();
        return [...complex.take((complex.length * 0.5).round()), ...difficult];
      case 'a': // Advanced - 30% complex, 30% difficult, 40% advanced
        final complex = allQuestions.where((q) => q.complexity == QuestionComplexity.complex).toList();
        final difficult = allQuestions.where((q) => q.complexity == QuestionComplexity.difficult).toList();
        final advanced = allQuestions.where((q) => q.complexity == QuestionComplexity.advanced).toList();
        return [
          ...complex.take((complex.length * 0.3).round()),
          ...difficult.take((difficult.length * 0.3).round()),
          ...advanced
        ];
      default:
        return allQuestions;
    }
  }

  void _setExamDuration() {
    switch (currentLevel) {
      case 's':
      case 'm':
        duration = const Duration(minutes: 120);
        break;
      case 'c':
      case 'd':
      case 'a':
        duration = const Duration(minutes: 150);
        break;
      default:
        duration = const Duration(minutes: 120);
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
    await prefs.setBool('mock_exam_is_pcb', widget.isPCB); // Save PCB flag
    await prefs.setString('mock_exam_questions', jsonEncode(questionsJson));
  }

  Future<void> _saveExamResult() async {
    final examAttemptsJson = prefs.getString('mock_exam_attempts') ?? '[]';
    final List<dynamic> examAttempts = jsonDecode(examAttemptsJson);

    final examResult = {
      'title': widget.title,
      'date': examStartTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'duration': (duration.inMinutes).toString(),
      'correct': correct,
      'wrong': wrong,
      'total': questions.length,
      'subjectId': widget.subjectId,
      'isPCB': widget.isPCB, // Save whether this was PCB or PCM
      'score': (correct / questions.length * 100).toStringAsFixed(1),
    };

    examAttempts.add(examResult);
    await prefs.setString('mock_exam_attempts', jsonEncode(examAttempts));

    // Update general stats
    final totalAttempts = prefs.getInt('total_mock_exam_attempts') ?? 0;
    await prefs.setInt('total_mock_exam_attempts', totalAttempts + 1);

    // Update high score if needed
    final highScore = prefs.getInt('mock_exam_high_score') ?? 0;
    if (correct > highScore) {
      await prefs.setInt('mock_exam_high_score', correct);
    }

    // Update subject-specific stats with PCB/PCM distinction
    final subjectKey = 'mock_exam_stats_${widget.subjectId}_${widget.isPCB ? "PCB" : "PCM"}';
    final subjectStatsJson = prefs.getString(subjectKey) ?? '{"attempts": 0, "high_score": 0}';
    final subjectStats = jsonDecode(subjectStatsJson);
    subjectStats['attempts'] = (subjectStats['attempts'] as int) + 1;
    if (correct > (subjectStats['high_score'] as int)) {
      subjectStats['high_score'] = correct;
    }
    await prefs.setString(subjectKey, jsonEncode(subjectStats));
  }

  Future<bool> _loadExamState() async {
    final savedSubjectId = prefs.getString('mock_exam_subject_id');
    final savedIsPCB = prefs.getBool('mock_exam_is_pcb') ?? false;

    if (savedSubjectId == null || savedSubjectId != widget.subjectId || savedIsPCB != widget.isPCB) {
      return false;
    }

    final questionsJson = prefs.getString('mock_exam_questions');
    if (questionsJson != null) {
      final decoded = jsonDecode(questionsJson) as List<dynamic>;
      setState(() {
        questions = decoded.map((e) => SubCahpDatum.fromJson(e)).toList();
        isLoadingFirstQuestion = false;
      });
    }

    final startTimeStr = prefs.getString('mock_exam_start_time');
    final remainingTime = prefs.getInt('mock_exam_remaining_time') ?? 7200;
    if (startTimeStr != null && startTimeStr.isNotEmpty) {
      final savedStartTime = DateTime.parse(startTimeStr);
      final now = DateTime.now();
      final elapsedSeconds = now.difference(savedStartTime).inSeconds;
      final updatedRemainingTime = remainingTime - elapsedSeconds;
      duration = Duration(seconds: updatedRemainingTime > 0 ? updatedRemainingTime : 0);
    } else {
      duration = Duration(seconds: remainingTime);
    }

    setState(() {
      currentIndex = prefs.getInt('mock_exam_current_index') ?? 0;
      correct = prefs.getInt('mock_exam_correct') ?? 0;
      wrong = prefs.getInt('mock_exam_wrong') ?? 0;
      selectedAnswers = prefs.getStringList('mock_exam_selected_answers') ?? List.filled(questions.length, '');
      selectedOption = selectedAnswers[currentIndex].isNotEmpty ? selectedAnswers[currentIndex] : null;
      examStartTime = DateTime.now();
      timerStarted = true;
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingFirstQuestion && questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions.isNotEmpty ? questions[currentIndex] : null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      bottomNavigationBar:InkWell(
        onTap: () async {
          // Save the selected answer if any
          if (selectedOption != null) {
            selectedAnswers[currentIndex] = selectedOption!;
          }

          countdownTimer?.cancel();
          await _saveExamState();

          // Navigate back
          Navigator.pop(context);

          //Get.back();
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 50,
                    maxHeight: MediaQuery.of(context).size.height * 0.5, // Use 50% of screen height
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: MathText(
                      expression: question?.question ?? '',
                      height: estimateHeight(question?.question ?? ''),
                    ),
                  ),
                ),
              ),
              ...List.generate(4, (index) {
                final opt = question?.toJson()['option_${index + 1}'];
                if (opt == null || opt.toString().trim().isEmpty) return const SizedBox();
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                  ),
                  child: ListTile(
                    title: MathText(expression: opt, height: estimateOptionsHeight(opt)),
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

// ... (keep existing methods like _startTimer, _submitAnswer, _showResultPopup,
// estimateHeight, estimateOptionsHeight, etc. unchanged)

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
  Future<void> _showResultPopup() async {
    // Save the exam result first
    await _saveExamResult();

    // Clear the saved state since exam is completed
    await _clearSavedExamState();

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
    if (text.isEmpty) return 0;

    // Count lines considering:
    // 1. Actual newlines
    // 2. Long lines that will wrap
    // 3. Math expressions that take more vertical space
    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt') || text.contains(r'\(');

    //print("Lines="+ lines.toString() + "LongLines=" + longLines.toString());
    // Base height calculation
    double height = (lines + longLines) * 20.0;
    height = height * 2.5;
    // Add extra space for complex math expressions
    if (hasComplexMath) {
      height += 30.0;
    }

    // Minimum and maximum height constraints
    return height.clamp(50.0, 300.0); // Adjust max height as needed
  }

  double estimateOptionsHeight(String text) {
    if (text.isEmpty) return 0;

    // Count lines considering:
    // 1. Actual newlines
    // 2. Long lines that will wrap
    // 3. Math expressions that take more vertical space
    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt');

    //print("Lines="+ lines.toString() + "LongLines=" + longLines.toString());
    // Base height calculation
    double height = (lines + longLines) * 10.0;
    //height = height * 2.5;
    // Add extra space for complex math expressions
    if (hasComplexMath) {
      height += 30.0;
    }

    // Minimum and maximum height constraints
    return height.clamp(50.0, 300.0); // Adjust max height as needed
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

// Add this enum at the top of the file
enum QuestionComplexity {
  simple,
  medium,
  complex,
  difficult,
  advanced
}
