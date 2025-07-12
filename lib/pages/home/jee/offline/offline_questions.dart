/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/pages/text_answer/text_answer.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class OfflineQuestions extends StatefulWidget {
  final String chapterId;
  const OfflineQuestions({required this.chapterId, super.key});

  @override
  State<OfflineQuestions> createState() => _OfflineQuestionsState();
}

class _OfflineQuestionsState extends State<OfflineQuestions> {
  List<dynamic> sigmaData = [];
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool showEvaluation = false;
  List<Map<String, dynamic>> userAnswers = [];
  Map<int, bool> bookmarkedQuestions = {};
  Map<int, bool> showTextAnswer = {};
  Map<int, bool> showExplanation = {};
  Map<int, bool> showNotes = {};

  @override
  void initState() {
    super.initState();
    getQuestionList();
  }

  getQuestionList() async {
    final prefs = await SharedPreferences.getInstance();
    var board = prefs.getString('board') == "Maharashtra" ? "MH/" : prefs.getString('board');

    var inputFile = await SdCardUtility.getSubjectEncJsonData('jee/mcq/${widget.chapterId}.json');
    if (inputFile != null) {
      var parsedJson = jsonDecode(inputFile);
      print("Parsed ${parsedJson.length}");
      setState(() {
        sigmaData = parsedJson["sigma_data"].take(20).toList();
      });
    }
  }

  void toggleShowTextAnswer(int index) {
    setState(() {
      showTextAnswer[index] = !(showTextAnswer[index] ?? false);
    });
  }

  void toggleShowExplanation(int index) {
    setState(() {
      showExplanation[index] = !(showExplanation[index] ?? false);
    });
  }

  void toggleShowNotes(int index) {
    setState(() {
      showNotes[index] = !(showNotes[index] ?? false);
    });
  }

  void submitAnswer() {
    if (selectedAnswer == null) return;

    bool isCorrect = selectedAnswer == sigmaData[currentQuestionIndex]["answer"];

    userAnswers.add({
      "question": sigmaData[currentQuestionIndex]["question"],
      "selected": selectedAnswer,
      "correct": sigmaData[currentQuestionIndex]["answer"],
      "options": [
        sigmaData[currentQuestionIndex]["option_1"],
        sigmaData[currentQuestionIndex]["option_2"],
        sigmaData[currentQuestionIndex]["option_3"],
        sigmaData[currentQuestionIndex]["option_4"],
        sigmaData[currentQuestionIndex]["option_5"],
      ],
      "explanation": sigmaData[currentQuestionIndex]["ans_explaination"] ?? "No explanation available",
      "notes": sigmaData[currentQuestionIndex]["notes"] ?? "No notes available",
      "text_answer": sigmaData[currentQuestionIndex]["ans_explaination"] ?? "No text answer available",
    });

    setState(() {
      if (isCorrect) {
        correctAnswers++;
      } else {
        wrongAnswers++;
      }

      if (currentQuestionIndex < sigmaData.length - 1) {
        currentQuestionIndex++;
        selectedAnswer = null;
      } else {
        showResult = true;
      }
    });
  }

  void toggleBookmark(int questionIndex) {
    setState(() {
      bookmarkedQuestions[questionIndex] = !(bookmarkedQuestions[questionIndex] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sigmaData.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (showResult) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz Result")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Quiz Completed!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("Correct Answers: $correctAnswers", style: const TextStyle(fontSize: 18, color: Colors.green)),
              Text("Wrong Answers: $wrongAnswers", style: const TextStyle(fontSize: 18, color: Colors.red)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showEvaluation = true;
                        showResult = false;
                      });
                    },
                    child: const Text("Evaluation"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Back"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (showEvaluation) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Evaluation"),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () {
                // Show all bookmarked questions
                // You can implement this functionality if needed
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: userAnswers.length,
          itemBuilder: (context, index) {
            var questionData = userAnswers[index];
            bool isCorrect = questionData["selected"] == questionData["correct"];

            return Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: MathText(
                              expression: "Q${index + 1}: ${questionData['question']}" ,
                              height: 100,
                              //style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            bookmarkedQuestions[index] ?? false
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: bookmarkedQuestions[index] ?? false
                                ? Colors.blue
                                : null,
                          ),
                          onPressed: () => toggleBookmark(index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Options with color coding
                    Column(
                      children: questionData["options"]
                          .where((option) => option != null && option != "NA")
                          .map<Widget>((option) {
                        Color optionColor = Colors.white;
                        if (option == questionData["correct"]) {
                          optionColor = Colors.green.withOpacity(0.2);
                        } else if (option == questionData["selected"] && option != questionData["correct"]) {
                          optionColor = Colors.red.withOpacity(0.2);
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: optionColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: option == questionData["correct"]
                                  ? Colors.green
                                  : option == questionData["selected"]
                                  ? Colors.red
                                  : Colors.black,
                              width: option == questionData["correct"] || option == questionData["selected"] ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            title: MathText(expression: option,  height:80 ,),
                            leading: option == questionData["correct"]
                                ? const Icon(Icons.check, color: Colors.green)
                                : option == questionData["selected"] && !isCorrect
                                ? const Icon(Icons.close, color: Colors.red)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),

                    // Result indicator
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCorrect ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.error,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCorrect ? "Correct Answer!" : "Wrong Answer!",
                            style: TextStyle(
                              color: isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(
                            showTextAnswer[index] ?? false ? Icons.visibility_off : Icons.visibility,
                            size: 18,
                          ),
                          label: Text(showTextAnswer[index] ?? false ? "Hide Answer" : "Show Answer"),
                          onPressed: () {
                            print("Questionsss $questionData");
                            Get.to(TextAnswer(imagePath: questionData["text_answer"], title: "MCQ",basePath: "nr",stream: 'jee',));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[50],
                            foregroundColor: Colors.blue,
                          ),
                        ),
                        */
/*ElevatedButton.icon(
                          icon: Icon(
                            showExplanation[index] ?? false ? Icons.visibility_off : Icons.visibility,
                            size: 18,
                          ),
                          label: Text(showExplanation[index] ?? false ? "Hide Explanation" : "Show Explanation"),
                          onPressed: () => toggleShowExplanation(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[50],
                            foregroundColor: Colors.green,
                          ),
                        ),*//*

                        */
/*ElevatedButton.icon(
                          icon: Icon(
                            showNotes[index] ?? false ? Icons.visibility_off : Icons.visibility,
                            size: 18,
                          ),
                          label: Text("Notepad"),
                          onPressed: () => toggleShowNotes(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[50],
                            foregroundColor: Colors.orange,
                          ),
                        ),*//*

                      ],
                    ),

                    // Text Answer (shown when toggled)
                    if (showTextAnswer[index] ?? false)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Text Answer:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(questionData["text_answer"]),
                          ],
                        ),
                      ),

                    // Explanation (shown when toggled)
                    if (showExplanation[index] ?? false)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Explanation:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(questionData["explanation"]),
                          ],
                        ),
                      ),

                    // Notes (shown when toggled)
                    if (showNotes[index] ?? false)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Notes:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(questionData["notes"]),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    var questionData = sigmaData[currentQuestionIndex];
    List<String> options = [];

    for (int i = 1; i <= 5; i++) {
      String key = "option_$i";
      if (questionData[key] != null && questionData[key] != "NA") {
        options.add(questionData[key]);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("Question ${currentQuestionIndex + 1}/${sigmaData.length}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MathText(key: ValueKey('question_$currentQuestionIndex'), expression: questionData["question"], height: 100),
              const SizedBox(height: 15),
              Column(
                children: options.map((option) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black),
                    ),
                    child: RadioListTile<String>(
                      title: MathText(key: ValueKey('option_${options.indexOf(option)}_$currentQuestionIndex'),expression: option, height: 80),
                      value: option,
                      groupValue: selectedAnswer,
                      onChanged: (value) {
                        setState(() {
                          selectedAnswer = value;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: submitAnswer,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/pages/text_answer/text_answer.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

import '../../../../ui_helper/constant.dart';

class OfflineQuestions extends StatefulWidget {
  final String chapterId;
  final String title;

  const OfflineQuestions({required this.chapterId,required this.title, super.key});

  @override
  State<OfflineQuestions> createState() => _OfflineQuestionsState();
}

class _OfflineQuestionsState extends State<OfflineQuestions> {
  List<dynamic> sigmaData = [];
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool showEvaluation = false;
  List<Map<String, dynamic>> userAnswers = [];
  Map<int, bool> bookmarkedQuestions = {};
  Map<int, bool> showTextAnswer = {};
  Map<int, bool> showExplanation = {};
  Map<int, bool> showNotes = {};

  @override
  void initState() {
    super.initState();
    getQuestionList();
  }

  getQuestionList() async {
    final prefs = await SharedPreferences.getInstance();
    var board = prefs.getString('board') == "Maharashtra" ? "MH/" : prefs.getString('board');

    var inputFile = await SdCardUtility.getSubjectEncJsonData('jee/mcq/${widget.chapterId}.json');
    if (inputFile != null) {
      var parsedJson = jsonDecode(inputFile);
      List<dynamic> questions = parsedJson["sigma_data"];
      questions.shuffle(); // 🔀 Shuffle questions randomly

      setState(() {
        sigmaData = questions.take(20).toList(); // 📉 Limit to first 20 after shuffle
      });
    }
  }


  Future<void> saveUserAnswersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final attempt = {
      "subject": widget.title,        // <-- Add subject name
      "chapter": widget.title,          // <-- Chapter ID or name
      "timestamp": DateTime.now().toIso8601String(),
      "questions": userAnswers              // <-- List of answered questions
    };

    await prefs.setString('offline_quiz_${widget.chapterId}', jsonEncode(attempt));

    saveMockAttemptsToSDCard();
  }

  void submitAnswer() {
    if (selectedAnswer == null) return;

    bool isCorrect = selectedAnswer == sigmaData[currentQuestionIndex]["answer"];

    userAnswers.add({
      "question": sigmaData[currentQuestionIndex]["question"],
      "selected": selectedAnswer,
      "correct": sigmaData[currentQuestionIndex]["answer"],
      "options": [
        sigmaData[currentQuestionIndex]["option_1"],
        sigmaData[currentQuestionIndex]["option_2"],
        sigmaData[currentQuestionIndex]["option_3"],
        sigmaData[currentQuestionIndex]["option_4"],
        sigmaData[currentQuestionIndex]["option_5"],
      ],
      "explanation": sigmaData[currentQuestionIndex]["ans_explaination"] ?? "No explanation available",
      "notes": sigmaData[currentQuestionIndex]["notes"] ?? "No notes available",
      "text_answer": sigmaData[currentQuestionIndex]["ans_explaination"] ?? "No text answer available",
    });

    setState(() {
      if (isCorrect) {
        correctAnswers++;
      } else {
        wrongAnswers++;
      }

      if (currentQuestionIndex < sigmaData.length - 1) {
        currentQuestionIndex++;
        selectedAnswer = null;
      } else {
        showResult = true;
        saveUserAnswersToPrefs(); // 🔄 Save after last question
      }
    });
  }

  void toggleBookmark(int questionIndex) {
    setState(() {
      bookmarkedQuestions[questionIndex] = !(bookmarkedQuestions[questionIndex] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sigmaData.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (showResult) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz Result")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Quiz Completed!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("Correct Answers: $correctAnswers", style: const TextStyle(fontSize: 18, color: Colors.green)),
              Text("Wrong Answers: $wrongAnswers", style: const TextStyle(fontSize: 18, color: Colors.red)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showEvaluation = true;
                        showResult = false;
                      });
                    },
                    child: const Text("Evaluation"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Back"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (showEvaluation) {
      return Scaffold(
        appBar: AppBar(title: const Text("Evaluation")),
        body: ListView.builder(
          itemCount: userAnswers.length,
          itemBuilder: (context, index) {
            var questionData = userAnswers[index];
            bool isCorrect = questionData["selected"] == questionData["correct"];

            return Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: MathText(
                            expression: "Q${index + 1}: ${questionData['question']}",
                            height: 100,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            bookmarkedQuestions[index] ?? false
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: bookmarkedQuestions[index] ?? false ? Colors.blue : null,
                          ),
                          onPressed: () => toggleBookmark(index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: questionData["options"]
                          .where((option) => option != null && option != "NA")
                          .map<Widget>((option) {
                        Color optionColor = Colors.white;
                        if (option == questionData["correct"]) {
                          optionColor = Colors.green.withOpacity(0.2);
                        } else if (option == questionData["selected"] && option != questionData["correct"]) {
                          optionColor = Colors.red.withOpacity(0.2);
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: optionColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: option == questionData["correct"]
                                  ? Colors.green
                                  : option == questionData["selected"]
                                  ? Colors.red
                                  : Colors.black,
                              width: option == questionData["correct"] || option == questionData["selected"] ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            title: MathText(expression: option, height: 80),
                            leading: option == questionData["correct"]
                                ? const Icon(Icons.check, color: Colors.green)
                                : option == questionData["selected"] && !isCorrect
                                ? const Icon(Icons.close, color: Colors.red)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isCorrect ? Colors.green : Colors.red),
                      ),
                      child: Row(
                        children: [
                          Icon(isCorrect ? Icons.check_circle : Icons.error,
                              color: isCorrect ? Colors.green : Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            isCorrect ? "Correct Answer!" : "Wrong Answer!",
                            style: TextStyle(
                              color: isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text("Show Answer"),
                      onPressed: () {
                        Get.to(TextAnswer(
                          imagePath: questionData["text_answer"],
                          title: "MCQ",
                          basePath: "nr",
                          stream: 'jee',
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    var questionData = sigmaData[currentQuestionIndex];
    List<String> options = [];

    for (int i = 1; i <= 5; i++) {
      String key = "option_$i";
      if (questionData[key] != null && questionData[key] != "NA") {
        options.add(questionData[key]);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("Question ${currentQuestionIndex + 1}/${sigmaData.length}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MathText(
                  key: ValueKey('question_$currentQuestionIndex'),
                  expression: questionData["question"],
                  height: _estimateHeight(questionData["question"])),
              const SizedBox(height: 15),
              Column(
                children: options.map((option) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black),
                    ),
                    child: RadioListTile<String>(
                      title: MathText(
                          key: ValueKey('option_${options.indexOf(option)}_$currentQuestionIndex'),
                          expression: option,
                          height: _estimateOptionsHeight(option)),
                      value: option,
                      groupValue: selectedAnswer,
                      onChanged: (value) {
                        setState(() {
                          selectedAnswer = value;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: (){
                  submitAnswer();
                  // Get.to(LastMinuteRevision(path: widget.path,));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
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
                  child: const Text('Submit', style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<void> saveMockAttemptsToSDCard() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> currentAttempts = {};

    for (var key in prefs.getKeys()) {
      if (key.startsWith('offline_quiz_')) {
        final jsonStr = prefs.getString(key);
        if (jsonStr != null) {
          currentAttempts[key] = jsonDecode(jsonStr);
        }
      }
    }

    final directory = await SdCardUtility.getBasePath();
    final filePath = '$directory/mock_exam_attempts.json';
    final file = File(filePath);

    Map<String, List<dynamic>> existingAttempts = {};

    // Load existing attempts
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final decoded = jsonDecode(content);
        if (decoded is Map<String, dynamic>) {
          decoded.forEach((key, value) {
            if (value is List) {
              existingAttempts[key] = value;
            }
          });
        }
      } catch (e) {
        print("Error reading existing file: $e");
      }
    }

    bool hasNewData = false;

    for (var key in currentAttempts.keys) {
      final newAttempt = currentAttempts[key];

      // Ensure list exists
      existingAttempts.putIfAbsent(key, () => []);

      // Check for duplicate timestamp before adding
      final timestamp = newAttempt['timestamp'];
      final alreadyExists = existingAttempts[key]!.any(
            (attempt) => attempt['timestamp'] == timestamp,
      );

      if (!alreadyExists) {
        existingAttempts[key]!.add(newAttempt);
        hasNewData = true;
      }
    }

    if (hasNewData) {
      await file.writeAsString(jsonEncode(existingAttempts));
      print("Mock attempts appended to: $filePath");
    } else {
      print("No new attempt to append.");
    }
  }


  double _estimateOptionsHeight(String text) {
    if (text.isEmpty) return 0;

    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt');

    double height = (lines + longLines) * 40.0;

    if (hasComplexMath) {
      height += 45.0;
    }

    return height.clamp(50.0, 300.0);
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

}
