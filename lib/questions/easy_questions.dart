import 'dart:math';

import 'package:flutter/material.dart';

import 'package:sigma_new/ui_helper/constant.dart';

class EasyQuestions extends StatefulWidget {
  List<dynamic> easyQuestion;
  EasyQuestions({required this.easyQuestion, super.key});

  @override
  State<EasyQuestions> createState() => _EasyQuestionsState();
}

class _EasyQuestionsState extends State<EasyQuestions> {
  final List<Map<String, dynamic>> questions = [
    {
      "index": "1",
      "question": "If p is any statement, then (p^p)?",
      "options": ["Option 1", "Option 2", "Option 3", "Option 4"]
    },
    {
      "index": "2",
      "question": "What is the capital of France?",
      "options": ["Berlin", "Madrid", "Paris", "Rome"]
    },
    {
      "index": "3",
      "question": "Solve: 5 + 3 * 2",
      "options": ["16", "11", "10", "13"]
    },
    {
      "index": "1",
      "question": "If p is any statement, then (p^p)?",
      "options": ["Option 1", "Option 2", "Option 3", "Option 4"]
    },
    {
      "index": "2",
      "question": "What is the capital of France?",
      "options": ["Berlin", "Madrid", "Paris", "Rome"]
    },
    {
      "index": "3",
      "question": "Solve: 5 + 3 * 2",
      "options": ["16", "11", "10", "13"]
    },
    {
      "index": "1",
      "question": "If p is any statement, then (p^p)?",
      "options": ["Option 1", "Option 2", "Option 3", "Option 4"]
    },
    {
      "index": "2",
      "question": "What is the capital of France?",
      "options": ["Berlin", "Madrid", "Paris", "Rome"]
    },
    {
      "index": "3",
      "question": "Solve: 5 + 3 * 2",
      "options": ["16", "11", "10", "13"]
    },
  ];

  List<dynamic> selectedQuestions = [];
  bool isLoading = false;

  /*@override
  void initState() {
    super.initState();
    selectRandomQuestions();
  }*/

  void selectRandomQuestions() {
    isLoading=true;
    if (widget.easyQuestion.isNotEmpty) {

      List<dynamic> tempList = List.from(widget.easyQuestion); // Copy list
      tempList.shuffle(Random()); // Shuffle the list randomly
      setState(() {


        selectedQuestions = tempList.take(30).toList();
        // Take 30 random questions
      });
      isLoading =false;

    }

  }

  @override
  Widget build(BuildContext context) {
    selectRandomQuestions();
    return  isLoading ? const SizedBox(
      height: 10,
        child: LinearProgressIndicator()):ListView.builder(
      physics: const ScrollPhysics(),
      itemCount: selectedQuestions.length,
      itemBuilder: (context, index) {

        var question = selectedQuestions[index]["question"];
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "${index+1}",
                    style: primaryColor16w500TextStyleInter,
                  ),
                ),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: primaryColor),
                  ),
                ),
              ],
            ),

            height5Space,
            /*...List.generate(question[].length, (i) {
              // "${String.fromCharCode(65 + i)}. ${question['options'][i]}"
              return Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.045,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          side: const BorderSide(
                              color: greyColor, width: 1.0), // Purple border
                          backgroundColor: whiteColor // Black text color
                          ),
                      onPressed: () {},
                      child: Text(
                        "${String.fromCharCode(65 + i)}. ${question['options'][i]}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: blackColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),*/
            /*Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.045,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(
                              color: primaryColor, width: 1.0), // Purple border
                          // Black text color
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Notes",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: primaryColor, // Black text color
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.045,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: whiteColor,
                          backgroundColor: primaryColor,
                        ),
                        onPressed: () {},
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
                ),
              ],
            ),*/
            const Divider(
              color: primaryColor, // Color of the divider
              thickness: 1.5, // Thickness of the divider
              indent: 5.0, // Start offset of the divider from the left
              endIndent: 5.0, // End offset of the divider from the right
            ),
          ],
        );
      },
    );
  }
}
