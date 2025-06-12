import 'dart:async';
import 'dart:convert';
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
  final bool isPCB;

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

  // Updated question counts - 50 Physics, 50 Chemistry, 98 Math/Bio
  final int PHYSICS_Q_COUNT = 50;
  final int CHEMISTRY_Q_COUNT = 50;
  final int MATH_Q_COUNT = 98;
  final int BIOLOGY_Q_COUNT = 98;

  final String MAT_FILE_PREFIX = "jeemcqmathch";
  final String PHY_FILE_PREFIX = "jeemcqphych";
  final String CHE_FILE_PREFIX = "jeemcqchech";
  final String BIO_FILE_PREFIX = "jeemcqbioch";

  int correct = 0;
  int wrong = 0;

  Timer? countdownTimer;
  Duration duration = const Duration(minutes: 180); // 3 hours for full mock
  bool timerStarted = false;

  String? selectedOption;
  DateTime? examStartTime;
  bool isLoadingFirstQuestion = true;
  String currentLevel = 'm'; // Default to medium level

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
      // Start loading all questions in the specified order
      _loadAllQuestions().then((_) {
        setState(() {
          isLoadingFirstQuestion = false;
        });

        if (!timerStarted && questions.isNotEmpty) {
          examStartTime = DateTime.now();
          _startTimer();
          timerStarted = true;
        }
      });
    }
  }

  Future<void> _loadAllQuestions() async {
    if (!widget.isPCB) {
      // For PCM: Load Math first (98 questions)
      final mathFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", MAT_FILE_PREFIX) ?? [];
      final mathUri = FileUri(
        files: mathFiles,
        perChapterCount: mathFiles.isNotEmpty ? MATH_Q_COUNT ~/ mathFiles.length : 0,
        remainCount: mathFiles.isNotEmpty ? MATH_Q_COUNT % mathFiles.length : 0,
      );

      List<SubCahpDatum> mathQuestions = [];
      await _processFiles(mathUri, mathQuestions, "Math");

      // Ensure exactly 98 Math questions
      if (mathQuestions.length > MATH_Q_COUNT) {
        mathQuestions = mathQuestions.sublist(0, MATH_Q_COUNT);
      }

      // Then load Physics (50 questions)
      final phyFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", PHY_FILE_PREFIX) ?? [];
      final phyUri = FileUri(
        files: phyFiles,
        perChapterCount: phyFiles.isNotEmpty ? PHYSICS_Q_COUNT ~/ phyFiles.length : 0,
        remainCount: phyFiles.isNotEmpty ? PHYSICS_Q_COUNT % phyFiles.length : 0,
      );

      List<SubCahpDatum> physicsQuestions = [];
      await _processFiles(phyUri, physicsQuestions, "Physics");

      // Ensure exactly 50 Physics questions
      if (physicsQuestions.length > PHYSICS_Q_COUNT) {
        physicsQuestions = physicsQuestions.sublist(0, PHYSICS_Q_COUNT);
      }

      // Then load Chemistry (50 questions)
      final cheFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", CHE_FILE_PREFIX) ?? [];
      final cheUri = FileUri(
        files: cheFiles,
        perChapterCount: cheFiles.isNotEmpty ? CHEMISTRY_Q_COUNT ~/ cheFiles.length : 0,
        remainCount: cheFiles.isNotEmpty ? CHEMISTRY_Q_COUNT % cheFiles.length : 0,
      );

      List<SubCahpDatum> chemistryQuestions = [];
      await _processFiles(cheUri, chemistryQuestions, "Chemistry");

      // Ensure exactly 50 Chemistry questions
      if (chemistryQuestions.length > CHEMISTRY_Q_COUNT) {
        chemistryQuestions = chemistryQuestions.sublist(0, CHEMISTRY_Q_COUNT);
      }

      setState(() {
        questions.addAll(mathQuestions);
        questions.addAll(physicsQuestions);
        questions.addAll(chemistryQuestions);
        selectedAnswers = List.filled(questions.length, '');

        // Verify total count (98 Math + 50 Physics + 50 Chem = 198)
       // assert(questions.length == MATH_Q_COUNT + PHYSICS_Q_COUNT + CHEMISTRY_Q_COUNT);
      });
    } else {
      // For PCB: Load Biology first (98 questions)
      final bioFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", BIO_FILE_PREFIX) ?? [];
      final bioUri = FileUri(
        files: bioFiles,
        perChapterCount: bioFiles.isNotEmpty ? BIOLOGY_Q_COUNT ~/ bioFiles.length : 0,
        remainCount: bioFiles.isNotEmpty ? BIOLOGY_Q_COUNT % bioFiles.length : 0,
      );

      List<SubCahpDatum> biologyQuestions = [];
      await _processFiles(bioUri, biologyQuestions, "Biology");

      // Ensure exactly 98 Biology questions
      if (biologyQuestions.length > BIOLOGY_Q_COUNT) {
        biologyQuestions = biologyQuestions.sublist(0, BIOLOGY_Q_COUNT);
      }

      // Then load Physics (50 questions)
      final phyFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", PHY_FILE_PREFIX) ?? [];
      final phyUri = FileUri(
        files: phyFiles,
        perChapterCount: phyFiles.isNotEmpty ? PHYSICS_Q_COUNT ~/ phyFiles.length : 0,
        remainCount: phyFiles.isNotEmpty ? PHYSICS_Q_COUNT % phyFiles.length : 0,
      );

      List<SubCahpDatum> physicsQuestions = [];
      await _processFiles(phyUri, physicsQuestions, "Physics");

      // Ensure exactly 50 Physics questions
      if (physicsQuestions.length > PHYSICS_Q_COUNT) {
        physicsQuestions = physicsQuestions.sublist(0, PHYSICS_Q_COUNT);
      }

      // Then load Chemistry (50 questions)
      final cheFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", CHE_FILE_PREFIX) ?? [];
      final cheUri = FileUri(
        files: cheFiles,
        perChapterCount: cheFiles.isNotEmpty ? CHEMISTRY_Q_COUNT ~/ cheFiles.length : 0,
        remainCount: cheFiles.isNotEmpty ? CHEMISTRY_Q_COUNT % cheFiles.length : 0,
      );

      List<SubCahpDatum> chemistryQuestions = [];
      await _processFiles(cheUri, chemistryQuestions, "Chemistry");

      // Ensure exactly 50 Chemistry questions
      if (chemistryQuestions.length > CHEMISTRY_Q_COUNT) {
        chemistryQuestions = chemistryQuestions.sublist(0, CHEMISTRY_Q_COUNT);
      }

      setState(() {
        questions.addAll(biologyQuestions);
        questions.addAll(physicsQuestions);
        questions.addAll(chemistryQuestions);
        selectedAnswers = List.filled(questions.length, '');

        // Verify total count (98 Bio + 50 Physics + 50 Chem = 198)
        assert(questions.length == BIOLOGY_Q_COUNT + PHYSICS_Q_COUNT + CHEMISTRY_Q_COUNT);
      });
    }

    // Shuffle all questions except the first few
    if (questions.length > 10) {
      final firstQuestions = questions.sublist(0, 10);
      final remainingQuestions = questions.sublist(10);
      remainingQuestions;

      setState(() {
        questions = firstQuestions + remainingQuestions;
      });
    }
  }


  Future<List<SubCahpDatum>> _loadFirstSubjectQuestions() async {
    final phyFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", PHY_FILE_PREFIX) ?? [];

    if (phyFiles.isEmpty) return [];

    final phyUri = FileUri(
      files: phyFiles,
      perChapterCount: phyFiles.isNotEmpty ? PHYSICS_Q_COUNT ~/ phyFiles.length : 0,
      remainCount: phyFiles.isNotEmpty ? PHYSICS_Q_COUNT % phyFiles.length : 0,
    );

    List<SubCahpDatum> physicsQuestions = [];
    await _processFiles(phyUri, physicsQuestions, "Physics");

    // Ensure we have exactly 50 Physics questions
    if (physicsQuestions.length > PHYSICS_Q_COUNT) {
      physicsQuestions = physicsQuestions.sublist(0, PHYSICS_Q_COUNT);
    }

    return physicsQuestions;
  }

  Future<void> _loadRemainingQuestions() async {
    // Load Chemistry (50 questions)
    final cheFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", CHE_FILE_PREFIX) ?? [];
    final cheUri = FileUri(
      files: cheFiles,
      perChapterCount: cheFiles.isNotEmpty ? CHEMISTRY_Q_COUNT ~/ cheFiles.length : 0,
      remainCount: cheFiles.isNotEmpty ? CHEMISTRY_Q_COUNT % cheFiles.length : 0,
    );

    List<SubCahpDatum> chemistryQuestions = [];
    await _processFiles(cheUri, chemistryQuestions, "Chemistry");

    // Ensure exactly 50 Chemistry questions
    if (chemistryQuestions.length > CHEMISTRY_Q_COUNT) {
      chemistryQuestions = chemistryQuestions.sublist(0, CHEMISTRY_Q_COUNT);
    }

    if (!widget.isPCB) {
      // Load Math (98 questions for PCM)
      final mathFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", MAT_FILE_PREFIX) ?? [];
      final mathUri = FileUri(
        files: mathFiles,
        perChapterCount: mathFiles.isNotEmpty ? MATH_Q_COUNT ~/ mathFiles.length : 0,
        remainCount: mathFiles.isNotEmpty ? MATH_Q_COUNT % mathFiles.length : 0,
      );

      List<SubCahpDatum> mathQuestions = [];
      await _processFiles(mathUri, mathQuestions, "Math");

      // Ensure exactly 98 Math questions
      if (mathQuestions.length > MATH_Q_COUNT) {
        mathQuestions = mathQuestions.sublist(0, MATH_Q_COUNT);
      }

      setState(() {
        questions.addAll(chemistryQuestions);
        questions.addAll(mathQuestions);
        selectedAnswers = List.filled(questions.length, '');

        // Verify total count (50 Physics + 50 Chem + 98 Math = 198)
        assert(questions.length == PHYSICS_Q_COUNT + CHEMISTRY_Q_COUNT + MATH_Q_COUNT);
      });
    } else {
      // Load Biology (98 questions for PCB)
      final bioFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", BIO_FILE_PREFIX) ?? [];
      final bioUri = FileUri(
        files: bioFiles,
        perChapterCount: bioFiles.isNotEmpty ? BIOLOGY_Q_COUNT ~/ bioFiles.length : 0,
        remainCount: bioFiles.isNotEmpty ? BIOLOGY_Q_COUNT % bioFiles.length : 0,
      );

      List<SubCahpDatum> biologyQuestions = [];
      await _processFiles(bioUri, biologyQuestions, "Biology");

      // Ensure exactly 98 Biology questions
      if (biologyQuestions.length > BIOLOGY_Q_COUNT) {
        biologyQuestions = biologyQuestions.sublist(0, BIOLOGY_Q_COUNT);
      }

      setState(() {
        questions.addAll(chemistryQuestions);
        questions.addAll(biologyQuestions);
        selectedAnswers = List.filled(questions.length, '');

        // Verify total count (50 Physics + 50 Chem + 98 Bio = 198)
        assert(questions.length == PHYSICS_Q_COUNT + CHEMISTRY_Q_COUNT + BIOLOGY_Q_COUNT);
      });
    }

    // Shuffle all questions except the first few
    if (questions.length > 10) {
      final firstQuestions = questions.sublist(0, 10);
      final remainingQuestions = questions.sublist(10);
      remainingQuestions.shuffle();

      setState(() {
        questions = firstQuestions + remainingQuestions;
      });
    }
  }

  Future<void> _processFiles(FileUri uriGroup, List<SubCahpDatum> targetList, String subject) async {
    for (int i = 0; i < uriGroup.files.length; i++) {
      final file = uriGroup.files[i];
      final jsonStr = await SdCardUtility.getSubjectEncJsonDataForMock(file.path);
      if (jsonStr == null) continue;

      final decoded = jsonDecode(jsonStr);
      if (decoded == null || decoded['sigma_data'] == null) continue;

      final sigmaList = decoded['sigma_data'] as List<dynamic>;
      final allQuestions = sigmaList.map((e) {
        final question = SubCahpDatum.fromJson(e);
        // Set the subject for each question
        question.subject = subject;
        return question;
      }).toList();

      // Filter questions based on current level
      List<SubCahpDatum> filteredQuestions = _filterQuestionsByComplexity(allQuestions);

      int takeCount = uriGroup.perChapterCount + (i < uriGroup.remainCount ? 1 : 0);
      targetList.addAll(filteredQuestions.take(takeCount));
    }

    // After processing all files for a subject, verify we got the expected count
    int expectedCount = 0;
    if (subject == "Physics") expectedCount = PHYSICS_Q_COUNT;
    else if (subject == "Chemistry") expectedCount = CHEMISTRY_Q_COUNT;
    else if (subject == "Math") expectedCount = MATH_Q_COUNT;
    else if (subject == "Biology") expectedCount = BIOLOGY_Q_COUNT;

    if (targetList.length < expectedCount) {
      print("Warning: Only loaded ${targetList.length} $subject questions (expected $expectedCount)");
    } else if (targetList.length > expectedCount) {
      // Trim to exact count if we got too many
      targetList = targetList.sublist(0, expectedCount);
    }

    targetList.shuffle();
  }

  List<SubCahpDatum> _filterQuestionsByComplexity(List<SubCahpDatum> allQuestions) {
    switch (currentLevel) {
      case 's': // Simple - 100% simple
        return allQuestions.where((q) => q.complexity == 's').toList();
      case 'm': // Medium - 40% simple, 60% medium
        final simple = allQuestions.where((q) => q.complexity == 's').toList();
        final medium = allQuestions.where((q) => q.complexity == 'm').toList();
        return [...simple.take((simple.length * 0.4).round()), ...medium];
      case 'c': // Complex - 40% medium, 60% complex
        final medium = allQuestions.where((q) => q.complexity == 'm').toList();
        final complex = allQuestions.where((q) => q.complexity == 'c').toList();
        return [...medium.take((medium.length * 0.4).round()), ...complex];
      case 'd': // Difficult - 50% complex, 50% difficult
        final complex = allQuestions.where((q) => q.complexity == 'c').toList();
        final difficult = allQuestions.where((q) => q.complexity == 'd').toList();
        return [...complex.take((complex.length * 0.5).round()), ...difficult];
      case 'a': // Advanced - 30% complex, 30% difficult, 40% advanced
        final complex = allQuestions.where((q) => q.complexity == 'c').toList();
        final difficult = allQuestions.where((q) => q.complexity == 'd').toList();
        final advanced = allQuestions.where((q) => q.complexity == 'a').toList();
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
    // Full mock exam duration (3 hours)
    duration = const Duration(minutes: 180);
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
    await prefs.setBool('mock_exam_is_pcb', widget.isPCB);
    await prefs.setString('mock_exam_questions', jsonEncode(questionsJson));
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
    final remainingTime = prefs.getInt('mock_exam_remaining_time') ?? 10800; // 3 hours in seconds
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
      'isPCB': widget.isPCB,
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

    // Update subject-specific stats
    final subjectKey = 'mock_exam_stats_${widget.subjectId}_${widget.isPCB ? "PCB" : "PCM"}';
    final subjectStatsJson = prefs.getString(subjectKey) ?? '{"attempts": 0, "high_score": 0}';
    final subjectStats = jsonDecode(subjectStatsJson);
    subjectStats['attempts'] = (subjectStats['attempts'] as int) + 1;
    if (correct > (subjectStats['high_score'] as int)) {
      subjectStats['high_score'] = correct;
    }
    await prefs.setString(subjectKey, jsonEncode(subjectStats));
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
    await prefs.remove('mock_exam_questions');
    await prefs.remove('mock_exam_is_pcb');
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

  Future<void> _showResultPopup() async {
    await _saveExamResult();
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

  @override
  Widget build(BuildContext context) {
    if (isLoadingFirstQuestion && questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions.isNotEmpty ? questions[currentIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Question Distribution"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Physics: ${questions.where((q) => q.subject == "Physics").length}/50"),
                      Text("Chemistry: ${questions.where((q) => q.subject == "Chemistry").length}/50"),
                      if (!widget.isPCB)
                        Text("Mathematics: ${questions.where((q) => q.subject == "Math").length}/98"),
                      if (widget.isPCB)
                        Text("Biology: ${questions.where((q) => q.subject == "Biology").length}/98"),
                      const SizedBox(height: 10),
                      Text("Total: ${questions.length}/198"),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: InkWell(
        onTap: () async {
          if (selectedOption != null) {
            selectedAnswers[currentIndex] = selectedOption!;
          }
          countdownTimer?.cancel();
          await _saveExamState();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Test paused. You can resume where you left off.'))
          );
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
                  'Time Left: ${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
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
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: MathText(
                      key: ValueKey(question?.question),
                      expression: question?.question ?? '',
                      height: _estimateHeight(question?.question ?? ''),
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
                    title: MathText(key: ValueKey("_${opt}"),expression: opt, height: _estimateOptionsHeight(opt)),
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

  double _estimateHeight(String text) {
    if (text.isEmpty) return 0;

    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt') || text.contains(r'\(');

    double height = (lines + longLines) * 20.0;
    height = height * 2.5;

    if (hasComplexMath) {
      height += 30.0;
    }

    return height.clamp(50.0, 300.0);
  }

  double _estimateOptionsHeight(String text) {
    if (text.isEmpty) return 0;

    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt');

    double height = (lines + longLines) * 20.0;

    if (hasComplexMath) {
      height += 40.0;
    }

    return height.clamp(50.0, 300.0);
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