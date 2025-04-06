import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class JeeMockExam extends StatefulWidget {
  const JeeMockExam({super.key});

  @override
  State<JeeMockExam> createState() => _JeeMockExamState();
}

class _JeeMockExamState extends State<JeeMockExam> {


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
        'JEE/MCQ/sigma_data.json');

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Mock Exam'),

      ),
      body: Container(
        child: Column(
          children: [

          ],
        ),
      ),
    );
  }
}
