import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class OfflineQuestions extends StatefulWidget {
  final String chapterId;
  OfflineQuestions({required this.chapterId, super.key});

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
  List<Map<String, dynamic>> userAnswers = []; // Stores selected and correct answers

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
      setState(() {
        sigmaData = parsedJson["sigma_data"].take(20).toList();
      });
    }
  }

  void submitAnswer() {
    if (selectedAnswer == null) return;

    bool isCorrect = selectedAnswer == sigmaData[currentQuestionIndex]["answer"];

    // Save answer for evaluation
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
      ]
    });

    setState(() {
      if (isCorrect) {
        correctAnswers++;
      } else {
        wrongAnswers++;
      }
    });

    // Move to next question
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        if (currentQuestionIndex < sigmaData.length - 1) {
          currentQuestionIndex++;
          selectedAnswer = null; // Reset selection
        } else {
          showResult = true;
        }
      });
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
              Text("Quiz Completed!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("Correct Answers: $correctAnswers", style: TextStyle(fontSize: 18, color: Colors.green)),
              Text("Wrong Answers: $wrongAnswers", style: TextStyle(fontSize: 18, color: Colors.red)),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showEvaluation = true;
                        showResult = false;
                      });
                    },
                    child: Text("Evaluation"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Back"),
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

            return Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Q${index + 1}: ${questionData['question']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Column(
                      children: questionData["options"]
                          .where((option) => option != null && option != "NA")
                          .map<Widget>((option) {
                        Color optionColor = Colors.white;
                        if (option == questionData["correct"]) {
                          optionColor = Colors.green; // Correct answer
                        } else if (option == questionData["selected"]) {
                          optionColor = Colors.red; // Wrong selected answer
                        }

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: optionColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black),
                          ),
                          child: ListTile(
                            title: Text(option),
                          ),
                        );
                      }).toList(),
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
      appBar: AppBar(title: Text("Question ${currentQuestionIndex + 1}/20")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionData["question"],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 15),

            // Options
            Column(
              children: options.map((option) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                  ),
                  child: RadioListTile<String>(
                    title: Text(option),
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

            SizedBox(height: 20),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: submitAnswer,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
                child: Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
