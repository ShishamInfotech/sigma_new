import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/pages/home/home.dart';
import 'package:sigma_new/questions/easy_questions.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class TableQuiz extends StatefulWidget {
  final String pathQuestion;
  final String title;
  const TableQuiz({required this.pathQuestion, required this.title, super.key});

  @override
  State<TableQuiz> createState() => _TableQuizState();
}

class _TableQuizState extends State<TableQuiz> with TickerProviderStateMixin {
  String instructions = "";
  int _secondsRemaining = 9000; // 150 minutes
  Timer? _timer;
  bool quizStarted = false;
  bool isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> selectedQuestions = [];

  Map<String, dynamic> parsedJson = {};
  List<dynamic> sigmaData = [];

  final List<dynamic> simple = [];
  final List<dynamic> medium = [];
  final List<dynamic> complex = [];
  final List<dynamic> difficult = [];
  final List<dynamic> advanced = [];
  final String title = "Level-1";
  @override
  void initState() {
    super.initState();
    _loadInstructions();
    getQuestionList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadInstructions() {
    instructions = getLevelInstructions(title);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Instructions"),
          content: SingleChildScrollView(child: Text(instructions)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    });
  }

  String getLevelInstructions(String title) {
    if (title.contains("Level-1")) {
      return "1. Total 30 questions will be asked\n\n"
          "2. The duration is 150 minutes\n\n"
          "3. All questions are from Simple category\n\n"
          "4. Solve the questions using answer sheet\n\n"
          "5. After exam, check model answers in Evaluation\n\n"
          "6. Complete 50 exams to unlock next level";
    } else if (title.contains("Level-2")) {
      return "1. Total 30 questions will be asked\n\n"
          "2. The duration is 150 minutes\n\n"
          "3. 10 Simple + 20 Medium questions\n\n"
          "4. Solve the questions using answer sheet\n\n"
          "5. After exam, check model answers in Evaluation\n\n"
          "6. Complete 30 exams to unlock next level";
    } else if (title.contains("Level-3")) {
      return "1. Total 30 questions will be asked\n\n"
          "2. The duration is 150 minutes\n\n"
          "3. 10 Simple + 10 Medium + 10 Complex\n\n"
          "4. Solve the questions using answer sheet\n\n"
          "5. After exam, check model answers in Evaluation\n\n"
          "6. Complete 30 exams to unlock next level";
    } else if (title.contains("Level-4")) {
      return "1. Total 30 questions will be asked\n\n"
          "2. The duration is 150 minutes\n\n"
          "3. 10 Medium + 10 Complex + 10 Difficult\n\n"
          "4. Solve the questions using answer sheet\n\n"
          "5. After exam, check model answers in Evaluation\n\n"
          "6. Complete 30 exams to unlock next level";
    } else if (title.contains("Level-5")) {
      return "1. Total 30 questions will be asked\n\n"
          "2. The duration is 150 minutes\n\n"
          "3. 10 Complex + 10 Difficult + 10 Advanced\n\n"
          "4. Solve the questions using answer sheet\n\n"
          "5. After exam, check model answers in Evaluation\n\n"
          "6. Complete 30 exams to unlock next level\n\n"
          "7. Complete all 170 exams to access any level";
    }
    return "General Mock Exam Instructions";
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> getQuestionList() async {
    try {
      String? board;
      final prefs = await SharedPreferences.getInstance();
      board = prefs.getString('board') == "Maharashtra"
          ? "MH/"
          : prefs.getString('board');

      String newPath = widget.pathQuestion.contains("10")
          ? "10/"
          : widget.pathQuestion.contains("12")
              ? "12/"
              : "";

      var inputFile = await SdCardUtility.getSubjectEncJsonData(
          '${newPath}${board}testseries/${widget.pathQuestion}.json');
      print(inputFile.toString());
      if (inputFile != null) {
        parsedJson = jsonDecode(inputFile);
        sigmaData = List.from(parsedJson["sigma_data"] ?? []);

        simple.clear();
        medium.clear();
        complex.clear();
        difficult.clear();
        advanced.clear();

        for (var data in sigmaData) {
          switch (data["complexity"]?.toString().toLowerCase()) {
            case "s":
              simple.add(data);
              break;
            case "m":
              medium.add(data);
              break;
            case "c":
              complex.add(data);
              break;
            case "d":
              difficult.add(data);
              break;
            case "a":
              advanced.add(data);
              break;
            default:
              simple.add(data);
          }
        }

        simple.shuffle();
        medium.shuffle();
        complex.shuffle();
        difficult.shuffle();
        advanced.shuffle();

        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading questions: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load questions")),
      );
    }
  }

  void _startQuiz() {
    if (!quizStarted && !isLoading) {
      setState(() {
        quizStarted = true;
        _secondsRemaining = 9000;
      });

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining == 0) {
          timer.cancel();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Time is Up!'),
              content: const Text('The quiz has ended.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                )
              ],
            ),
          );
        } else {
          setState(() => _secondsRemaining--);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerWidget(context),
      bottomNavigationBar: quizStarted
          ? InkWell(
              onTap: () {
                submitMockExam();
                //Get.to(const LastMinuteRevision());
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                    color: primaryColor,
                    boxShadow: const [
                      BoxShadow(
                        color: whiteColor,
                      )
                    ],
                    borderRadius: BorderRadius.circular(10)),
                height: 60,
                alignment: Alignment.center,
                child: const Text(
                  'Submit',
                  style:
                      TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : Container(
              height: 80,
            ),
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(isPortrait ? height * 0.13 : height * 0.5),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  backgroundColor,
                  backgroundColor,
                  backgroundColor,
                  whiteColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          title: Text(widget.title, style: black20w400MediumTextStyle),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          if (quizStarted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Time Remaining: ${formatTime(_secondsRemaining)}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: _startQuiz,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(quizStarted ? "Exam in Progress" : "Start Exam"),
            ),
          ),
          if (!quizStarted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                instructions,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : quizStarted
                    ? _buildQuestionList()
                    : _buildPlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Text(
        "Press 'Start Exam' to begin",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildQuestionList() {
    List<dynamic> questions = [];

    if (title.contains("Level-1")) {
      questions = simple.take(30).toList();
    } else if (widget.title.contains("Level-2")) {
      questions = [...simple.take(10), ...medium.take(20)];
    } else if (widget.title.contains("Level-3")) {
      questions = [...simple.take(10), ...medium.take(10), ...complex.take(10)];
    } else if (widget.title.contains("Level-4")) {
      questions = [
        ...medium.take(10),
        ...complex.take(10),
        ...difficult.take(10)
      ];
    } else if (widget.title.contains("Level-5")) {
      questions = [
        ...complex.take(10),
        ...difficult.take(10),
        ...advanced.take(10)
      ];
    }

    selectedQuestions = questions.asMap().entries.map((entry) {
      final index = entry.key;
      final question = Map<String, dynamic>.from(entry.value);
      question['serial'] = index + 1;
      return question;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: questions.length,
      itemBuilder: (context, index) {
       /* var questionWithSerial = Map<String, dynamic>.from(questions[index]);
        questionWithSerial['serial'] = index + 1; // Add serial number
  */   //   return EasyQuestions(easyQuestion: questionWithSerial);
        return EasyQuestions(easyQuestion: selectedQuestions[index]);
      },
    );
  }

  submitMockExam() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure want to submit?'),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();

                final newSubmission = {
                  'title': widget.title,
                  'timestamp': DateTime.now().toIso8601String(),
                  'questions': selectedQuestions,
                };

                // Load existing submissions
                final storedSubmissions = prefs.getString('mock_submissions');
                List<dynamic> allSubmissions = [];

                if (storedSubmissions != null) {
                  try {
                    allSubmissions = jsonDecode(storedSubmissions);
                  } catch (e) {
                    allSubmissions = [];
                  }
                }

                // Append new submission
                allSubmissions.add(newSubmission);

                // Optional: Keep only the last 30 submissions
                if (allSubmissions.length > 30) {
                  allSubmissions = allSubmissions.sublist(allSubmissions.length - 30);
                }

                // Save updated list
                await prefs.setString('mock_submissions', jsonEncode(allSubmissions));

                // Optionally: Navigate to homepage or evaluation
                Get.offAll(HomePage());
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('No'),
            )
          ],
        );
      },
    );
  }

}
