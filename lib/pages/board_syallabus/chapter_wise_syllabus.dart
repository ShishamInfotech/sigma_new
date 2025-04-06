/*
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/board_syallabus/topic_wise_syallabus.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class ChapterWiseSyllabus extends StatefulWidget {
  String? path;

  ChapterWiseSyllabus({this.path, super.key});

  @override
  _ChapterWiseSyllabusState createState() => _ChapterWiseSyllabusState();
}

class _ChapterWiseSyllabusState extends State<ChapterWiseSyllabus> {
  bool _showSideNav = true; // Toggle variable for the side navigation bar

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    subjectWiseTest();
  }

  List<String> subjects = [];
  Map<String, List<Map<String, dynamic>>> groupedData = {};
  // List<String> subjectsId = [];

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
    var newPath;
    var board;
    final prefs = await SharedPreferences.getInstance();
    String? course = prefs.getString('course');
    print(
        "Standard${prefs.getString('standard')} State:${prefs.getString('board')}");

    if (prefs.getString('board') == "Maharashtra") {
      board = "MH/";
    } else {
      board = prefs.getString('board');
    }

    if (widget.path!.contains("10")) {
      newPath = "10/";
    } else if (widget.path!.contains("12")) {
      newPath = "12/";
    }

    var inputFile = await SdCardUtility.getSubjectEncJsonData(
        '${newPath}${board}${widget.path}.json');

    print("INput File  $inputFile");
    Map<String, dynamic> parsedJson = jsonDecode(inputFile!);
    print("parsedJson $parsedJson");
    // Extracting subject values
    List<Map<String, dynamic>> sigmaData =
        List<Map<String, dynamic>>.from(parsedJson["sigma_data"]);

    // Get all subjects
    subjects = sigmaData.map((data) => data["subject"].toString()).toList();
    //subjectsId = sigmaData.map((data) => data["subjectid"].toString()).toList();

    //removeTestSeriesFromSubjectTitle(subjects);

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
    print(subjects.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.chevron_right, size: 24),
            SizedBox(width: 8),
            Text(
              widget.path!,
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
                  return ExpansionTile(
                    title: Text(
                      "${entry.key}: ${entry.value[0]["chapter"]}",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    children: entry.value.map((item) {
                      return ListTile(
                        title: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "${item["subchapter_number"]}: ${item["subchapter"]}" ??
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
    );
  }

  void onSublistItemClick(Map<String, dynamic> item) {
    // Handle item click
    print("Clicked on: ${item["subchapter"]}");

    Get.to(TopicWiseSyllabus(pathQuestion: item));

  }
}
*/


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/board_syallabus/topic_wise_syallabus.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class ChapterWiseSyllabus extends StatefulWidget {
  String? path;

  ChapterWiseSyllabus({this.path, super.key});

  @override
  _ChapterWiseSyllabusState createState() => _ChapterWiseSyllabusState();
}

class _ChapterWiseSyllabusState extends State<ChapterWiseSyllabus> {
  bool _showSideNav = true;

  @override
  void initState() {
    super.initState();
    subjectWiseTest();
  }

  List<String> subjects = [];
  Map<String, List<Map<String, dynamic>>> groupedData = {};

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
    var newPath;
    var board;
    final prefs = await SharedPreferences.getInstance();
    String? course = prefs.getString('course');

    if (prefs.getString('board') == "Maharashtra") {
      board = "MH/";
    } else {
      board = prefs.getString('board');
    }

    if (widget.path!.contains("10")) {
      newPath = "10/";
    } else if (widget.path!.contains("12")) {
      newPath = "12/";
    }

    var inputFile = await SdCardUtility.getSubjectEncJsonData(
        '${newPath}${board}${widget.path}.json');

    Map<String, dynamic> parsedJson = jsonDecode(inputFile!);

    List<Map<String, dynamic>> sigmaData =
    List<Map<String, dynamic>>.from(parsedJson["sigma_data"]);

    subjects = sigmaData.map((data) => data["subject"].toString()).toList();

    if (sigmaData.isNotEmpty) {
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.chevron_right, size: 24),
            SizedBox(width: 8),
            Text(
              widget.path!,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, size: 28),
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
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
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
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    children: entry.value.map((item) {
                      return ListTile(
                        title: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "${item["subchapter_number"]}: ${item["subchapter"]}" ??
                                "No Subchapter",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
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
    );
  }

  void onSublistItemClick(Map<String, dynamic> item) {
    print("Clicked on: ${item["subchapter"]}");
    Get.to(TopicWiseSyllabus(pathQuestion: item));
  }

  /*void onSublistItemClick(Map<String, dynamic> item) {
    // Find all subchapters under the same chapter
    final String chapterNumber = item["chapter_number"].toString();
    final List<Map<String, dynamic>> subchapterList = groupedData[chapterNumber] ?? [];

    // Navigate and pass the list instead of a single item
    Get.to(TopicWiseSyllabus(pathQuestionList: subchapterList));
  }*/
}
