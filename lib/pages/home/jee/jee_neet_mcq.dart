import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sigma_new/pages/home/jee/mcq_questions/view_questions.dart';
import 'package:sigma_new/pages/home/jee/offline/offline_questions.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

import '../../drawer/drawer.dart';

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
  // Use a scaffold key to open drawer from AppBar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    subjectWiseTest();
  }

  subjectWiseTest() async {
    var inputFile = await SdCardUtility.getSubjectEncJsonData(
        'JEE/MCQ/${widget.subjectId}.json');

    if (inputFile == null) return;
    Map<String, dynamic> parsedJson = jsonDecode(inputFile);
    List<Map<String, dynamic>> sigmaData =
    List<Map<String, dynamic>>.from(parsedJson["sigma_data"]);

    subjects = sigmaData.map((data) => data["chapter"].toString()).toList();
    subjectsId = sigmaData.map((data) => data["chapterid"].toString()).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
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
            // open the drawer
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),

      // <-- here we attach your existing drawer implementation
      drawer: const DrawerWidget(),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
          child: ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  "${index + 1}: ${subjects[index]}",
                  style: black16MediumTextStyle,
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  if (widget.title.toLowerCase().contains("offline")) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Begin Exam ?'),
                          actions: [
                            TextButton(
                              child: const Text('Yes'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Get.to(OfflineQuestions(chapterId: subjectsId[index], title: subjects[index]));
                              },
                            ),
                            TextButton(
                              child: const Text('No'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Get.to(ViewQuestions(chapterId: subjectsId[index]));
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
