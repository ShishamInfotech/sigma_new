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
  }*/

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

    // Filtering only records where complexity is "a" or "e"
    sigmaData = sigmaData.where((data) {
      String complexity = data["complexity"].toString().toLowerCase();
      return complexity == widget.complexity;
    }).toList();

    // Group data by chapter
    groupedData.clear();
    for (var item in sigmaData) {
      String chapterName = item["chapter"].toString(); // Use chapter name for grouping

      if (!groupedData.containsKey(chapterName)) {
        groupedData[chapterName] = [];
      }
      groupedData[chapterName]!.add(item);
    }

    // Update subjects list based on grouped data
    subjects = groupedData.keys.toList();

    print("Grouped Chapters (Complexity: A or E): $groupedData");

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
        title: Row(
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
          icon: Icon(Icons.menu, size: 28),
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
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(5, 0),
                      ),
                    ],
                  ),
                  child: Column(
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
              duration: Duration(milliseconds: 300),
              left: _showSideNav ? screenWidth * 0.18 : screenWidth * 0.05,
              right: screenWidth * 0.05,
              top: screenHeight * 0.04,
              bottom: screenHeight * 0.03,
              child: ListView(
                children: groupedData.entries.map((entry) {
                  int chapterIndex = groupedData.keys.toList().indexOf(entry.key) + 1;
                  return ExpansionTile(
                    title: Text(
                      "${chapterIndex}: ${entry.value[0]["chapter"]}",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    children: entry.value.asMap().entries.map((subEntry)  {
                      int subIndex = subEntry.key + 1;
                      var item = subEntry.value;
                      return ListTile(
                        title: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "$chapterIndex.$subIndex: ${item["subchapter"]}" ??
                                "No Subchapter",
                            style: TextStyle(fontSize: 16),

                          ),

                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),

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
    final String subchapterNumber = item["subchapter_number"];
    final List<Map<String, dynamic>> allQuestions = [];

    for (var chapter in groupedData.values) {
      allQuestions.addAll(chapter.where((q) =>
      q["subchapter_number"].toString().toLowerCase().trim() ==
          subchapterNumber.toLowerCase().trim()));
    }

    Get.to(() => TopicWiseSyllabus(pathQuestionList: allQuestions, subjectId: item["subjectid"]));
  }

}
