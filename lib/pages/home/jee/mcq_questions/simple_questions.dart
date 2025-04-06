import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:sigma_new/ui_helper/constant.dart';

class SimpleQuestions extends StatefulWidget {
  final List<dynamic> easyQuestion;

  SimpleQuestions({required this.easyQuestion, super.key});

  @override
  State<SimpleQuestions> createState() => _SimpleQuestionsState();
}

class _SimpleQuestionsState extends State<SimpleQuestions> {
  List<dynamic> selectedQuestions = [];
  bool isLoading = false;
  bool isInitialized = false;
  Map<int, String?> selectedAnswers = {}; // Store selected answers per question
  Map<int, bool?> answerResults = {};
  // Store correct/wrong status per question


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("SimpleQuestions: didChangeDependencies called");
    // You can reinitialize your question list here
  }

  @override
  Widget build(BuildContext context) {


    /*if (!isInitialized) {
      selectRandomQuestions();
      isInitialized = true;
    }*/

   // selectRandomQuestions();




    return ListView.builder(
      physics: const ScrollPhysics(),
      itemCount: widget.easyQuestion.length,
      itemBuilder: (context, index) {
        var questionData = widget.easyQuestion[index];
        var question = questionData["question"];
        String correctAnswer = questionData["answer"];

        // Extract options dynamically
        List<String> options = [];
        for (int i = 1; i <= 5; i++) {
          String key = "option_$i";
          if (questionData[key] != null && questionData[key] != "NA") {
            options.add(questionData[key]);
          }
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Display Question
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "${index + 1}.",
                    style: primaryColor16w500TextStyleInter,
                  ),
                ),
                Expanded(
                  child: Math.tex(
                    preprocessLaTeX(question),
                    textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: primaryColor),
                  ),
                ),
              ],
            ),
            height5Space,

            // Show options with radio buttons and color feedback
            Column(
              children: options.map((option) {
                bool isCorrect = option == correctAnswer;
                bool isSubmitted = answerResults.containsKey(index);

                return Container(
                  decoration: BoxDecoration(
                    color: isSubmitted
                        ? (isCorrect
                        ? Colors.green.withOpacity(0.2) // Green for correct
                        : (selectedAnswers[index] == option
                        ? Colors.red.withOpacity(0.2) // Red for wrong
                        : Colors.transparent))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RadioListTile<String>(
                    title: Text(
                      option,
                      style: TextStyle(
                        color: isSubmitted
                            ? (isCorrect
                            ? Colors.green // Green text for correct
                            : (selectedAnswers[index] == option
                            ? Colors.red // Red text for wrong
                            : Colors.black))
                            : Colors.black,
                      ),
                    ),
                    value: option,
                    groupValue: selectedAnswers[index],
                    onChanged: isSubmitted
                        ? null // Disable selection after submission
                        : (value) {
                      setState(() {
                        selectedAnswers[index] = value;
                      });
                    },
                  ),
                );
              }).toList(),
            ),

            // Show submit button only when an option is selected
            if (selectedAnswers[index] != null && !answerResults.containsKey(index))
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: whiteColor,
                      backgroundColor: primaryColor,
                    ),
                    onPressed: () {
                      bool isCorrect = selectedAnswers[index] == correctAnswer;

                      setState(() {
                        answerResults[index] = isCorrect;
                      });

                      // Show feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isCorrect ? "✅ Correct!" : "❌ Wrong! Correct Answer: $correctAnswer",
                          ),
                          backgroundColor: isCorrect ? Colors.green : Colors.red,
                        ),
                      );
                    },
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

            const Divider(
              color: primaryColor,
              thickness: 1.5,
              indent: 5.0,
              endIndent: 5.0,
            ),
          ],
        );
      },
    );
  }

  String preprocessLaTeX(String question) {
    return question
        .replaceAll(r"\(", " ")
        .replaceAll(r"\)", " ")
        .replaceAll(r"\[", " ")
        .replaceAll(r"\]", " ")
        .replaceAll(r"$", " ")
        .replaceAll(r"\right", " ")
        .replaceAll(r"\leqb", " ");
  }
}
