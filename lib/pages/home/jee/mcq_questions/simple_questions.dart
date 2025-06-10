import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/pages/text_answer/text_answer.dart';
import 'package:sigma_new/ui_helper/constant.dart';

import '../../../notepad/noteswrite.dart';

class SimpleQuestions extends StatefulWidget {
  final List<dynamic> easyQuestion;

  SimpleQuestions({required this.easyQuestion, super.key});

  @override
  State<SimpleQuestions> createState() => _SimpleQuestionsState();
}

class _SimpleQuestionsState extends State<SimpleQuestions> {
  Map<int, String?> selectedAnswers = {}; // Store selected answers per question
  Map<int, bool?> answerResults = {}; // Store correct/wrong status per question

  @override
  Widget build(BuildContext context) {
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
                  child: MathText(
                    expression: question,
                    height: 150,
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
                        ? Colors.green.withOpacity(0.2)
                        : (selectedAnswers[index] == option
                        ? Colors.red.withOpacity(0.2)
                        : Colors.transparent))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black),
                    ),
                    child: RadioListTile<String>(
                      title: MathText(expression: option, height: 35),
                      value: option,
                      groupValue: selectedAnswers[index],
                      onChanged: isSubmitted
                          ? null
                          : (value) {
                        setState(() {
                          selectedAnswers[index] = value;
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),

            // Submit Button
            if (selectedAnswers[index] != null &&
                !answerResults.containsKey(index))
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: whiteColor,
                      backgroundColor: primaryColor,
                    ),
                    onPressed: () {
                      bool isCorrect =
                          selectedAnswers[index] == correctAnswer;

                      setState(() {
                        answerResults[index] = isCorrect;
                      });

                      // Show feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isCorrect
                                ? "✅ Correct!"
                                : "❌ Wrong! Correct Answer: $correctAnswer",
                          ),
                          backgroundColor:
                          isCorrect ? Colors.green : Colors.red,
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

            // Action Buttons Row
            if (answerResults.containsKey(index))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: FutureBuilder<bool>(
                  future: isBookmarked(questionData["contentcode"]),
                  builder: (context, snapshot) {
                    final bookmarked = snapshot.data ?? false;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton("Text Answer", Icons.article, () {
                          // TODO: Implement Text Answer View
                          Get.to(TextAnswer(
                            imagePath: questionData["ans_explaination"],
                            title: "MCQ",
                            stream: questionData["stream"],
                            basePath: "nr",));
                        }),
                        /*_buildActionButton("Explanation", Icons.info_outline, () {
                        // TODO: Implement Explanation View
                        _showSnack("Explanation tapped");
                      }),*/
                        _buildActionButton("Notepad", Icons.note_add, () {
                          // TODO: Implement Notes Feature
                          Get.to(() =>
                              NotepadPage(
                                subjectId: questionData["contentcode"].toString() ??
                                    "unknown",
                                chapter: questionData["chapter"] ?? "chapter",
                              ));
                        }),
                        TextButton(
                          onPressed: () =>
                              toggleBookmark(questionData["contentcode"]),
                          child: Text(bookmarked ? "Unbookmark" : "Bookmark"),
                        ),
                      ],
                    );
                  },),
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

  Future<bool> isBookmarked(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarked = prefs.getStringList('bookmarks') ?? [];
    return bookmarked.contains(id);
  }

  Future<void> toggleBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarked = prefs.getStringList('bookmarks') ?? [];
    if (bookmarked.contains(id)) {
      bookmarked.remove(id);
    } else {
      bookmarked.add(id);
    }
    await prefs.setStringList('bookmarks', bookmarked);
    setState(() {});
  }

  Widget _buildActionButton(
      String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 18,color: blackColor,),
      label: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
      onPressed: onPressed,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 1),
    ));
  }
}
