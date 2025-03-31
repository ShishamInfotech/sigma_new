import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sigma_new/pages/home/jee/mcq_questions/view_questions.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class JeeNeetMcq extends StatefulWidget {
  String title;
  String subjectId;
  JeeNeetMcq({required this.title, required this.subjectId, super.key});

  @override
  State<JeeNeetMcq> createState() => _JeeNeetMcqState();
}

class _JeeNeetMcqState extends State<JeeNeetMcq> {
  List<String> subjects = [];
  List<String> subjectsId = [];
  bool _showSideNav = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    subjectWiseTest();
  }

  subjectWiseTest() async {
    var newPath;
    var board;

    var inputFile = await SdCardUtility.getSubjectEncJsonData(
        'JEE/MCQ/${widget.subjectId}.json');

    print("INput File  $inputFile");
    Map<String, dynamic> parsedJson = jsonDecode(inputFile!);
    print("parsedJson $parsedJson");
    // Extracting subject values
    List<Map<String, dynamic>> sigmaData =
        List<Map<String, dynamic>>.from(parsedJson["sigma_data"]);

    // Get all subjects
    subjects = sigmaData.map((data) => data["chapter"].toString()).toList();
    subjectsId = sigmaData.map((data) => data["chapterid"].toString()).toList();

    //removeTestSeriesFromSubjectTitle(subjects);

    /*if (sigmaData.isNotEmpty) {
      for (var item in sigmaData) {
        String subjectNumber =
        item["chapter_number"].toString(); // Ensure it's a String

        if (!groupedData.containsKey(subjectNumber)) {
          groupedData[subjectNumber] = [];
        }
        groupedData[subjectNumber]!.add(item);
      }
    }*/
    // Print subjects
    print(subjects);
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
            const Icon(Icons.chevron_right, size: 24),
            const SizedBox(width: 8),
            Text(
              "${widget.title}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              child: ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        "${index + 1}: ${subjects[index]}",
                        style: black16MediumTextStyle,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: (){
                        Get.to(ViewQuestions(chapterId: subjectsId[index],));
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
