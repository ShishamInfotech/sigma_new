/*
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sigma_new/pages/board_syallabus/topic_wise_syallabus.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';


class JeeNeetConcept extends StatefulWidget {
  String subjectId;
  String? complexity;
  JeeNeetConcept({required this.subjectId,this.complexity, super.key});

  @override
  State<JeeNeetConcept> createState() => _JeeNeetConceptState();
}

class _JeeNeetConceptState extends State<JeeNeetConcept> {

  List<String> subjects = [];
  List<String> complexitySubject = [];
  bool _showSideNav = true;
  Map<String, List<Map<String, dynamic>>> groupedData = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    subjectWiseTest();
  }

  */
/*subjectWiseTest() async {
    var newPath;
    var board;


    var inputFile = await SdCardUtility.getSubjectEncJsonData(
        'JEE/THEORY/${widget.subjectId}.json');

    print("INput File  $inputFile");

    Map<String, dynamic> parsedJson = jsonDecode(inputFile!);
    print("parsedJson $parsedJson");
    // Extracting subject values
    List<Map<String, dynamic>> sigmaData =
    List<Map<String, dynamic>>.from(parsedJson["sigma_data"]);

    // Get all subjects
    subjects = sigmaData.map((data) => data["chapter"].toString()).toList();
    complexitySubject = sigmaData.map((data) => data["complexity"].toString()).toList();
    //subjectsId = sigmaData.map((data) => data["subjectid"].toString()).toList();

    //removeTestSeriesFromSubjectTitle(subjects);

    print("Complexity $complexitySubject");

    if (sigmaData.isNotEmpty) {
      for (var item in sigmaData) {
        String subjectNumber =
        item["chapter_number"].toString(); // Ensure it's a String

        if (!groupedData.containsKey(subjectNumber)) {
          groupedData[subjectNumber] = [];
        }
        groupedData[subjectNumber]!.add(item);
      }
    }
    // Print subjects
    print(subjects);
    setState(() {});
  }*//*



  Map<String, List<Map<String, dynamic>>> groupedSubchapterQuestions = {};

  String removeTestSeriesFromSubjectTitle(String title) {
    if (title.toLowerCase().contains("test series")) {
      List<String> parts = title.split("-");
      if (parts.length > 1) {
        return "Board Mock Exam - ${parts[1].trim()}";
      }
    }
    return title;
  }

  subjectWiseTest() async {
    var inputFile = await SdCardUtility.getSubjectEncJsonData(
        'JEE/THEORY/${widget.subjectId}.json');

    if (inputFile == null) {
      print("Error: No data found!");
      return;
    }

    print("Input File: $inputFile");

    Map<String, dynamic> parsedJson = jsonDecode(inputFile);
    print("Parsed JSON: $parsedJson");

    // Extract sigma data
    List<Map<String, dynamic>> sigmaData =
    List<Map<String, dynamic>>.from(parsedJson["sigma_data"]);

    subjects = sigmaData.map((data) => data["subject"].toString()).toList();

    // Filtering only records where complexity is "a" or "e"
    if (sigmaData.isNotEmpty) {
      for (var item1 in sigmaData) {
        String subjectNumber = item1["subchapter_number"].toString();


        // Initialize the group if not present
        if (!groupedSubchapterQuestions.containsKey(subjectNumber)) {
          groupedSubchapterQuestions[subjectNumber] = [];
        } else {
          print(subjectNumber + ":" + item1.toString());
          groupedSubchapterQuestions[subjectNumber]!.add(item1);
        }
      }

      for (var item in sigmaData) {
        String subjectNumber = item["chapter_number"].toString();


        // Initialize the group if not present
        if (!groupedData.containsKey(subjectNumber)) {
          groupedData[subjectNumber] = [];
        }


        // Check for duplicates based on subchapter_number
        bool alreadyExists = groupedData[subjectNumber]!.any((existingItem) =>
        existingItem["subchapter_number"].toString().trim().toLowerCase() ==
            item["subchapter_number"].toString().trim().toLowerCase());

        if (!alreadyExists) {
          groupedData[subjectNumber]!.add(item);
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print("SubjectId ${widget.subjectId}");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.chevron_right, size: 24),
            const SizedBox(width: 8),
            Text(
              "MCQ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 28),
          onPressed: () {
            setState(() {
              _showSideNav = !_showSideNav; // Toggle side navigation visibility
            });
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 🔹 Side Navigation Bar (Show/Hide based on _showSideNav)
            if (_showSideNav)
              Positioned(
                top: screenHeight * 0.05,
                left: -10,
                child: Container(
                  width: screenWidth * 0.15,
                  height: screenHeight * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(5, 0),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.home, size: 30, color: Colors.black),
                      Icon(Icons.book, size: 30, color: Colors.black),
                      Icon(Icons.bar_chart, size: 30, color: Colors.black),
                      Icon(Icons.edit, size: 30, color: Colors.black),
                      Icon(Icons.search, size: 30, color: Colors.black),
                    ],
                  ),
                ),
              ),

            // 🔹 Main Content (Scrollable) - Adjust position when side nav is hidden
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _showSideNav ? screenWidth * 0.18 : screenWidth * 0.05,
              right: screenWidth * 0.05,
              top: screenHeight * 0.04,
              bottom: screenHeight * 0.03,
              child: ListView(
                children: groupedData.entries.map((entry) {
                  return ExpansionTile(
                    title: Text(
                      "${entry.key}: ${entry.value[0]["chapter"]}",
                      style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    children: entry.value.map((item) {
                      return ListTile(
                        title: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "${item["subchapter_number"]}: ${item["subchapter"]}" ??
                                "No Subchapter",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 18, color: Colors.grey),
                        onTap: () => onSublistItemClick(item),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );;
  }


  // void onSublistItemClick(Map<String, dynamic> item) {
  //   // Handle item click
  //   print("Clicked on: ${item["description_image_id"]}");
  //
  //   Get.to(TopicWiseSyllabus(pathQuestion: item, subjectId: widget.subjectId,));
  //
  // }

  void onSublistItemClick(Map<String, dynamic> item) {
    final String subchapterNumber = item["subchapter_number"]
        .toString()
        .trim()
        .toLowerCase();

    print("Sub Chapter No:=  "+subchapterNumber);

    final questions = groupedSubchapterQuestions[subchapterNumber];

    if (questions != null && questions.isNotEmpty) {
      Get.to(() =>
          TopicWiseSyllabus(
            pathQuestionList: questions,
            subjectId: item["subjectid"],
          ));
    } else {

      print("Item ${item}");
      Get.to(() =>
          TopicWiseSyllabus(
            pathQuestionList: [item],
            subjectId: item["subjectid"],
          ));

      */
/*Get.snackbar(
        "No Questions Found",
        "There are no questions available for this subchapter.",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );*//*

    }
  }

}
*/



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sigma_new/pages/board_syallabus/topic_wise_syallabus.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';


class JeeNeetConcept extends StatefulWidget {
  final String subjectId;
  final String? complexity;

  JeeNeetConcept({required this.subjectId, this.complexity, super.key});

  @override
  State<JeeNeetConcept> createState() => _JeeNeetConceptState();
}

class _JeeNeetConceptState extends State<JeeNeetConcept> {
  List<String> subjects = [];
  List<String> complexitySubject = [];
  bool _showSideNav = true;
  Map<String, List<Map<String, dynamic>>> groupedData = {};
  Map<String, List<Map<String, dynamic>>> groupedSubchapterQuestions = {};

  @override
  void initState() {
    super.initState();
    subjectWiseTest();
  }

  String removeTestSeriesFromSubjectTitle(String title) {
    if (title.toLowerCase().contains("test series")) {
      List<String> parts = title.split("-");
      if (parts.length > 1) {
        return "Board Mock Exam - ${parts[1].trim()}";
      }
    }
    return title;
  }

  subjectWiseTest() async {
    var inputFile = await SdCardUtility.getSubjectEncJsonData(
        'JEE/THEORY/${widget.subjectId}.json');

    if (inputFile == null) {
      print("Error: No data found!");
      return;
    }

    Map<String, dynamic> parsedJson = jsonDecode(inputFile);
    List<Map<String, dynamic>> sigmaData =
    List<Map<String, dynamic>>.from(parsedJson["sigma_data"]);

    // 🔹 Filter by complexity if provided
    if (widget.complexity != null) {
      sigmaData = sigmaData.where((item) {
        return item["complexity"]?.toString().toLowerCase() ==
            widget.complexity!.toLowerCase();
      }).toList();
    }

    subjects = sigmaData.map((data) => data["subject"].toString()).toList();

    groupedSubchapterQuestions.clear();
    groupedData.clear();

    for (var item1 in sigmaData) {
      String subchapterNumber = item1["subchapter_number"].toString();

      groupedSubchapterQuestions.putIfAbsent(subchapterNumber, () => []);
      groupedSubchapterQuestions[subchapterNumber]!.add(item1);
    }

    for (var item in sigmaData) {
      String chapterNumber = item["chapter_number"].toString();

      groupedData.putIfAbsent(chapterNumber, () => []);

      bool alreadyExists = groupedData[chapterNumber]!.any((existingItem) =>
      existingItem["subchapter_number"].toString().trim().toLowerCase() ==
          item["subchapter_number"].toString().trim().toLowerCase());

      if (!alreadyExists) {
        groupedData[chapterNumber]!.add(item);
      }
    }

    setState(() {});
  }

  void onSublistItemClick(Map<String, dynamic> item) {
    final String subchapterNumber =
    item["subchapter_number"].toString().trim().toLowerCase();

    final questions = groupedSubchapterQuestions[subchapterNumber];

    if (questions != null && questions.isNotEmpty) {
      Get.to(() => TopicWiseSyllabus(
        pathQuestionList: questions,
        subjectId: item["subjectid"],
      ));
    } else {
      Get.to(() => TopicWiseSyllabus(
        pathQuestionList: [item],
        subjectId: item["subjectid"],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.chevron_right, size: 24),
            SizedBox(width: 8),
            Text(
              "MCQ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 28),
          onPressed: () {
            setState(() {
              _showSideNav = !_showSideNav;
            });
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (_showSideNav)
              Positioned(
                top: screenHeight * 0.05,
                left: -10,
                child: Container(
                  width: screenWidth * 0.15,
                  height: screenHeight * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(5, 0),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.home, size: 30, color: Colors.black),
                      Icon(Icons.book, size: 30, color: Colors.black),
                      Icon(Icons.bar_chart, size: 30, color: Colors.black),
                      Icon(Icons.edit, size: 30, color: Colors.black),
                      Icon(Icons.search, size: 30, color: Colors.black),
                    ],
                  ),
                ),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _showSideNav ? screenWidth * 0.18 : screenWidth * 0.05,
              right: screenWidth * 0.05,
              top: screenHeight * 0.04,
              bottom: screenHeight * 0.03,
              child: ListView(
                children: [
                  if (widget.complexity != null)
                    /*Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Filtering by complexity: ${widget.complexity}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                    ),*/
                  ...groupedData.entries.map((entry) {
                    return ExpansionTile(
                      title: Text(
                        "${entry.key}: ${entry.value[0]["chapter"]}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      children: entry.value.map((item) {
                        return ListTile(
                          title: Container(
                            margin:
                            const EdgeInsets.symmetric(horizontal: 10),
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "${item["subchapter_number"]}: ${item["subchapter"]}" ??
                                  "No Subchapter",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 18, color: Colors.grey),
                          onTap: () => onSublistItemClick(item),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
