import 'dart:async';
import 'dart:convert';
import 'dart:developer';
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
  // Add this flag
  bool isExamCompleted = false;
  late SharedPreferences prefs;
  int currentIndex = 0;
  List<SubCahpDatum> questions = [];
  List<String> selectedAnswers = [];
  int correct = 0;
  int wrong = 0;
  Timer? countdownTimer;
  Duration duration = const Duration(minutes: 180);
  bool timerStarted = false;
  String? selectedOption;
  DateTime? examStartTime;
  bool isLoadingFirstQuestion = true;
  String currentLevel = 's';
  bool _isLoading = false;

  // Updated question counts - 50 Physics, 50 Chemistry, 98 Math/Bio


  static const _physicsQCount = 50;
  static const _chemistryQCount = 50;
  static const _mathQCount = 98;
  static const _biologyQCount = 98;
  static const _filePrefixes = {
    'Math': "jeemcqmathch",
    'Physics': "jeemcqphych",
    'Chemistry': "jeemcqchech",
    'Biology': "jeemcqbioch",
  };


  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    prefs = await SharedPreferences.getInstance();
    _loadCurrentLevel();
    _setExamDuration();

    final hasSavedState = await _loadExamState();
    if (!hasSavedState) {
      await _loadQuestionsInBatches();
    }
  }


  Future<void> _loadQuestionsInBatches() async {
    setState(() => _isLoading = true);

    try {
      if (!widget.isPCB) {
        // PCM: Math -> Physics -> Chemistry
        await _loadSubjectQuestions('Math', _mathQCount);
        await _loadSubjectQuestions('Physics', _physicsQCount);
        await _loadSubjectQuestions('Chemistry', _chemistryQCount);
      } else {
        // PCB: Biology -> Physics -> Chemistry
        await _loadSubjectQuestions('Biology', _biologyQCount);
        await _loadSubjectQuestions('Physics', _physicsQCount);
        await _loadSubjectQuestions('Chemistry', _chemistryQCount);
      }

      // Initial shuffle (keep first 10 stable)
      if (questions.length > 10) {
        final firstQuestions = questions.sublist(0, 10);
        final remainingQuestions = questions.sublist(10);
        setState(() {
          questions = firstQuestions + remainingQuestions;
          selectedAnswers = List.filled(questions.length, '');
        });
      }

      if (!timerStarted && questions.isNotEmpty) {
        examStartTime = DateTime.now();
        _startTimer();
        timerStarted = true;
      }
    } catch (e) {
      debugPrint("Error loading questions: $e");
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading questions: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoadingFirstQuestion = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSubjectQuestions(String subject, int targetCount) async {
    final prefix = _filePrefixes[subject]!;
    final files = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", prefix) ?? [];

    if (files.isEmpty) {
      debugPrint("No files found for $subject");
      return;
    }

    final perChapterCount = targetCount ~/ files.length;
    final remainCount = targetCount % files.length;

    final List<SubCahpDatum> subjectQuestions = [];

    // Process files in batches
    for (int i = 0; i < files.length; i++) {
      if (_isLoading == false) break; // If user navigated away

      final file = files[i];
      final takeCount = perChapterCount + (i < remainCount ? 1 : 0);

      try {
        final batch = await _loadQuestionBatch(file, subject, takeCount);
        subjectQuestions.addAll(batch);

        // Update UI periodically
        if (i % 2 == 0) {
          setState(() {
            questions.addAll(subjectQuestions);
            selectedAnswers = List.filled(questions.length, '');
          });
          subjectQuestions.clear();
          await Future.delayed(const Duration(milliseconds: 50)); // Yield to UI thread
        }
      } catch (e) {
        debugPrint("Error processing ${file.path}: $e");
      }
    }

    // Add remaining questions
    if (subjectQuestions.isNotEmpty) {
      setState(() {
        questions.addAll(subjectQuestions);
        selectedAnswers = List.filled(questions.length, '');
      });
    }

    // 🎯 Fallback: Ensure targetCount is met
    final actualCount = questions.where((q) => q.subject == subject).length;
    final shortfall = targetCount - actualCount;

    if (shortfall > 0) {
      debugPrint("Fallback: $subject is short by $shortfall questions. Retrying...");

      try {
        for (final file in files) {
          final batch = await _loadQuestionBatch(file, subject, shortfall);
          final filtered = batch.where((q) => !questions.contains(q)).toList();

          if (filtered.isNotEmpty) {
            setState(() {
              questions.addAll(filtered.take(shortfall));
              selectedAnswers = List.filled(questions.length, '');
            });
            break;
          }
        }
      } catch (e) {
        debugPrint("Fallback error for $subject: $e");
      }
    }

  }

  Future<List<SubCahpDatum>> _loadQuestionBatch(Uri file, String subject, int takeCount) async {
    final jsonStr = await SdCardUtility.getSubjectEncJsonDataForMock(file.path);
    if (jsonStr == null) return [];

    final decoded = jsonDecode(jsonStr);
    if (decoded == null || decoded['sigma_data'] == null) return [];

    final sigmaList = decoded['sigma_data'] as List<dynamic>;
    final allQuestions = sigmaList.map((e) {
      final question = SubCahpDatum.fromJson(e);
      question.subject = subject;
      return question;
    }).toList();

    allQuestions.shuffle();
    return _filterQuestionsByComplexity(allQuestions).take(takeCount).toList();
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

    // Calculate score percentage
    final scorePercentage = (correct / questions.length * 100);
    final formattedScore = scorePercentage.toStringAsFixed(1);

    // Combine each question with selected answer, correct answer, etc.
    final detailedQuestions = <Map<String, dynamic>>[];
    for (int i = 0; i < questions.length; i++) {
      detailedQuestions.add({
        "question": questions[i].question,
        "options": [
          questions[i].option1,
          questions[i].option2,
          questions[i].option3,
          questions[i].option4,
          questions[i].option5,
        ],
        "selected": selectedAnswers[i],
        "correct": questions[i].answer,
        "level": currentLevel, // Add current level to each question
      //  "explanation": questions[i].ansExplanation ?? "No explanation available",
      //  "notes": questions[i].notes ?? "No notes available",
      //  "text_answer": questions[i].ansExplanation ?? "No text answer available",
      });
    }

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
      'questions': detailedQuestions,
      'level': currentLevel, // Add current level to exam result
      'currentLevel': currentLevel
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
    //subjectStats['level'] = currentLevel;
    subjectStats['currentLevel'] = currentLevel;
    await prefs.setString(subjectKey, jsonEncode(subjectStats));

    // Level progression logic
    await _updateLevelProgression(scorePercentage);

    loadMockAttemptsMock();
  }

  Future<void> _updateLevelProgression(double scorePercentage) async {
    // Get current level progression data
    final progressionKey = 'level_progression_${widget.isPCB ? "PCB" : "PCM"}';
    final progressionJson = prefs.getString(progressionKey) ?? '{"current_level": "$currentLevel", "consecutive_passes": 0}';
    final progressionData = jsonDecode(progressionJson);

    String currentLevels = progressionData['current_level'] ?? 's';
    int consecutivePasses = progressionData['consecutive_passes'] ?? 0;

    // Check if user scored 70% or more
    if (scorePercentage >= 70) {
      consecutivePasses++;

      // Check if user qualifies for next level
      if (consecutivePasses >= 50) {
        // Move to next level
        final nextLevel = _getNextLevel(currentLevels);
        if (nextLevel != currentLevels) {
          currentLevels = nextLevel;
          consecutivePasses = 0; // Reset counter for new level

          // Show level up message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Congratulations! You\'ve advanced to $currentLevels level!'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } else {
      // Reset consecutive passes if score is below 70%
      consecutivePasses = 0;

      // Optionally: Demote to previous level if performance is poor
      // This is optional and can be removed if you don't want demotions
      if (scorePercentage < 50 && currentLevels != 's') {
        final prevLevel = _getPreviousLevel(currentLevels);
        currentLevels = prevLevel;
        consecutivePasses = 0;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You\'ve been moved back to $currentLevels level.'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }

    // Save updated progression data
    await prefs.setString(progressionKey, jsonEncode({
      'current_level': currentLevels,
      'consecutive_passes': consecutivePasses,
    }));

    // After updating the level, save it
    await _saveCurrentLevel();

    // Update the current level in state
    setState(() {
      this.currentLevel = currentLevels;
    });
  }

  String _getNextLevel(String currentLevel) {
    switch (currentLevel) {
      case 's': return 'm'; // Simple -> Medium
      case 'm': return 'c'; // Medium -> Complex
      case 'c': return 'd'; // Complex -> Difficult
      case 'd': return 'a'; // Difficult -> Advanced
      case 'a': return 'a'; // Advanced stays at Advanced
      default: return 's'; // Default to Simple
    }
  }

  String _getPreviousLevel(String currentLevel) {
    switch (currentLevel) {
      case 'a': return 'd'; // Advanced -> Difficult
      case 'd': return 'c'; // Difficult -> Complex
      case 'c': return 'm'; // Complex -> Medium
      case 'm': return 's'; // Medium -> Simple
      case 's': return 's'; // Simple stays at Simple
      default: return 's'; // Default to Simple
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
    if (questions.isEmpty || isExamCompleted) return; // Prevent submissions after completion

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
    if (isExamCompleted) return; // Prevent duplicate processing

    setState(() {
      isExamCompleted = true;
    });

    await _saveExamResult();
    await _clearSavedExamState();
    countdownTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder:  (ctx) => WillPopScope(
      onWillPop: () async {
        // Navigate all the way back when back button is pressed
        Navigator.pop(ctx);
        Navigator.pop(context);
        return false;
      },
      child: AlertDialog(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Loading questions..."),
              Text("This may take a moment", style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: _showQuestionDistribution,
            ),
          ],
        ),
        body: _buildContent(),
        bottomNavigationBar: _buildPauseButton(),
      ),
    );
  }

  Widget _buildContent() {
    if (questions.isEmpty) {
      return const Center(child: Text("No questions available"));
    }

    final question = questions[currentIndex];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimerAndProgress(),
          _buildQuestionCard(question),
          ..._buildOptions(question),
          _buildSubmitButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTimerAndProgress() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Left: ${_formatDuration(duration)}',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'Question ${currentIndex + 1} of ${questions.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    return '${d.inHours.toString().padLeft(2, '0')}:'
        '${(d.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }


  Widget _buildQuestionCard(SubCahpDatum question) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: MathText(
              key: ValueKey(question.question),
              expression: question.question ?? '',
              height: _estimateHeight(question.question ?? ''),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions(SubCahpDatum question) {
    return List.generate(4, (index) {
      final opt = question.toJson()['option_${index + 1}'];
      if (opt == null || opt.toString().trim().isEmpty) return const SizedBox();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Card(
          child: RadioListTile<String>(
            title: MathText(
              key: ValueKey("_${opt}"),
              expression: opt,
              height: _estimateOptionsHeight(opt),
            ),
            value: opt,
            groupValue: selectedOption,
            onChanged: (value) {
              setState(() => selectedOption = value);
            },
          ),
        ),
      );
    }).whereType<Widget>().toList();
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          minimumSize: Size(Get.width, 50),
        ),
        onPressed: selectedOption != null ? _onSubmitPressed : null,
        child: const Text(
          "Submit Answer",
          style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPauseButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: redColor,
          minimumSize: Size(Get.width, 50),
        ),
        onPressed: _onPausePressed,
        child: const Text(
          'Pause Test',
          style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _onSubmitPressed() {
    if (selectedOption == null) return;
    _submitAnswer(selectedOption!);
  }

  Future<void> _onPausePressed() async {
    if (selectedOption != null) {
      selectedAnswers[currentIndex] = selectedOption!;
    }
    await _saveExamState();
    countdownTimer?.cancel();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test paused. You can resume where you left off.')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (isExamCompleted) return true;

    final shouldPause = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pause Test?'),
        content: const Text('Your progress will be saved. You can resume later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pause'),
          ),
        ],
      ),
    ) ?? false;

    if (shouldPause) await _onPausePressed();
    return shouldPause;
  }

  void _showQuestionDistribution() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Question Distribution"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Physics: ${questions.where((q) => q.subject == "Physics").length}/$_physicsQCount"),
            Text("Chemistry: ${questions.where((q) => q.subject == "Chemistry").length}/$_chemistryQCount"),
            if (!widget.isPCB)
              Text("Mathematics: ${questions.where((q) => q.subject == "Math").length}/$_mathQCount"),
            if (widget.isPCB)
              Text("Biology: ${questions.where((q) => q.subject == "Biology").length}/$_biologyQCount"),
            const SizedBox(height: 10),
            Text("Total: ${questions.length}/${_mathQCount + _physicsQCount + _chemistryQCount}"),
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
  }


  double _estimateHeight(String text) {
    if (text.isEmpty) return 0;

    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt') || text.contains(r'\(');

    double height = (lines + longLines) * 30.0;
    height = height * 4.0;

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


  Future<void> loadMockAttemptsMock() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<Map<String, dynamic>>> temp = {};

    for (var key in prefs.getKeys()) {
      if (key.startsWith('mock_exam_attempts')) {
        final jsonStr = prefs.getString(key);
        if (jsonStr != null) {
          try {
            final decoded = jsonDecode(jsonStr);
            if (decoded is Map<String, dynamic>) {
              final subject = decoded['subjectId'] ?? decoded['subject'] ?? 'Unknown';
              temp.putIfAbsent(subject, () => []);
              temp[subject]!.add(decoded);
            } else if (decoded is List) {
              for (var attempt in decoded) {
                if (attempt is Map<String, dynamic>) {
                  final subject = attempt['subjectId'] ?? attempt['subject'] ?? 'Unknown';
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

    log("Mock Exam $temp");



    // Save to external storage
    await _saveToSDCard(temp);
  }



  Future<void> _saveToSDCard(Map<String, List<Map<String, dynamic>>> newData) async {

    try {
      final directory = await SdCardUtility.getBasePath();
     // final dir = Directory(directory);
      final filePath = '$directory/jee_exam_attempt.json';
      final file = File(filePath);

      // Ensure directory exists
     // await Directory(path).create(recursive: true);

      Map<String, List<Map<String, dynamic>>> existingData = {};

      // If file exists, read existing data
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          try {
            final decoded = jsonDecode(content);
            if (decoded is Map<String, dynamic>) {
              decoded.forEach((key, value) {
                if (value is List) {
                  existingData[key] = value
                      .whereType<Map<String, dynamic>>()
                      .toList();
                }
              });
            }
          } catch (e) {
            debugPrint("Error decoding existing file: $e");
          }
        }
      }

      // Append new data
      newData.forEach((subject, newAttempts) {
        existingData.putIfAbsent(subject, () => []);
        final existingDates = existingData[subject]!
            .map((e) => e['date'])
            .whereType<String>()
            .toSet(); // Collect existing dates

        for (var attempt in newAttempts) {
          final date = attempt['date'];
          if (date != null && !existingDates.contains(date)) {
            existingData[subject]!.add(attempt);
          }
        }
      });

      // Optional: Sort again if needed
      existingData.forEach((subject, attempts) {
        attempts.sort((a, b) {
          final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
          final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });
      });

      // Save updated data
      final updatedJson = jsonEncode(existingData);
      await file.writeAsString(updatedJson);
      debugPrint("Data appended and saved to: ${file.path}");
    } catch (e) {
      debugPrint("Failed to append/save to SD card: $e");
    }
  }


  Future<void> _saveCurrentLevel() async {
    // Create a unique key based on the stream type
    final levelKey = 'current_level_${widget.isPCB ? "PCB" : "PCM"}';

    // Save to SharedPreferences
    await prefs.setString(levelKey, currentLevel);

    // Save to SD card
    try {
      final directory = await SdCardUtility.getBasePath();
      final filePath = '$directory/jee_level_data.json';
      final file = File(filePath);

      Map<String, dynamic> levelData = {};

      // If file exists, read existing data
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          try {
            levelData = jsonDecode(content);
          } catch (e) {
            debugPrint("Error decoding level file: $e");
          }
        }
      }

      // Update level data for this stream
      levelData[levelKey] = {
        'level': currentLevel,
        'last_updated': DateTime.now().toIso8601String(),
      };

      // Save updated data
      await file.writeAsString(jsonEncode(levelData));
    } catch (e) {
      debugPrint("Failed to save level to SD card: $e");
    }
  }

  Future<void> _loadCurrentLevel() async {
    // Create a unique key based on the stream type
    final levelKey = 'current_level_${widget.isPCB ? "PCB" : "PCM"}';

    // Try loading from SharedPreferences first
    String? level = prefs.getString(levelKey);

    if (level == null) {
      // If not in SharedPreferences, try loading from SD card
      try {
        final directory = await SdCardUtility.getBasePath();
        final filePath = '$directory/jee_level_data.json';
        final file = File(filePath);

        if (await file.exists()) {
          final content = await file.readAsString();
          final levelData = jsonDecode(content);
          level = levelData[levelKey]?['level'];
        }
      } catch (e) {
        debugPrint("Error loading level from SD card: $e");
      }
    }

    setState(() {
      currentLevel = level ?? 's'; // Default to 's' if no level found
    });
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