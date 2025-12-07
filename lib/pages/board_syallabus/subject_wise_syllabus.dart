import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/board_syallabus/chapter_wise_syllabus.dart';
import 'package:sigma_new/pages/last_minute_revision/last_minute_revision.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

// add drawer import
import 'package:sigma_new/pages/drawer/drawer.dart';

class BoardWiseSyllabus extends StatefulWidget {
  String? path;

  BoardWiseSyllabus({this.path, super.key});

  @override
  _BoardWiseSyllabusState createState() => _BoardWiseSyllabusState();
}

class _BoardWiseSyllabusState extends State<BoardWiseSyllabus> {
  final List<Color> cardColors = [
    const Color(0xFFDBCDF0),
    const Color(0xFFF2C6DF),
    const Color(0xFFC9E4DF),
    const Color(0xFFF8D9C4),
    const Color(0xFFDBCDF0),
    const Color(0xFFF2C6DF),
    const Color(0xFFC9E4DF),
    const Color(0xFFF8D9C4),
  ];

  final List<Map<String, dynamic>> cardData = [
    {"title": "Board Mock Exam Mathematics-1", "icon": Icons.calculate},
    {"title": "Board Mock Exam Mathematics-2", "icon": Icons.functions},
    {"title": "Science & Technology Part-1", "icon": Icons.science},
    {"title": "Science & Technology Part-2", "icon": Icons.biotech},
    {"title": "Science & Technology Part-2", "icon": Icons.book},
    {"title": "Science & Technology Part-2", "icon": Icons.book},
    {"title": "Science & Technology Part-2", "icon": Icons.book},
    {"title": "Science & Technology Part-2", "icon": Icons.book},
    {"title": "Science & Technology Part-2", "icon": Icons.book},
  ];

  final List<List<String>> subPoints = [
    [],
    [],
    [],
    [
      "Chapter 1: Heredity and Evolution",
      "Chapter 2: Life Processes in Living Organisms Part -1",
      "Chapter 3: Life Processes in Living Organisms Part - 2",
    ]
  ];

  List<bool> isExpanded = [];
  // removed _showSideNav; we're using real drawer now

  @override
  void initState() {
    super.initState();
    subjectWiseTest();
  }

  List<String> subjects = [];
  List<String> subjectsId = [];

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
    print("Standard${prefs.getString('standard')} State:${prefs.getString('board')}");

    String? boardPref = prefs.getString('board');
    board = (boardPref != null && boardPref == "Maharashtra") ? "MH/" : "${boardPref ?? ""}/";

    if (widget.path!.contains("10")) {
      newPath = "10/";
    } else if (widget.path!.contains("12")) {
      newPath = "12/";
    }

    var inputFile = await SdCardUtility.getSubjectEncJsonData('${newPath}${board}sigma_data.json');

    print("INput File  $inputFile");
    Map<String, dynamic> parsedJson = jsonDecode(inputFile!);
    // Extracting subject values
    List<dynamic> sigmaData = parsedJson["sigma_data"];

    // Get all subjects
    subjects = sigmaData.map((data) => data["subject"].toString()).toList();
    subjectsId = sigmaData.map((data) => data["subjectid"].toString()).toList();

    // initialize isExpanded safely to subjects length
    isExpanded = List<bool>.filled(subjects.length, false);

    // Print subjects
    print(subjects);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,

      // keep your bottom button
      bottomNavigationBar: InkWell(
        onTap: () {
          Get.to(LastMinuteRevision(path: widget.path));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(color: primaryColor, boxShadow: const [BoxShadow(color: whiteColor)], borderRadius: BorderRadius.circular(10)),
          height: 60,
          alignment: Alignment.center,
          child: const Text(
            'Last Minute Revision',
            style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.chevron_right, size: 24),
            const SizedBox(width: 8),
            Text(
              widget.path ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // open real drawer via scaffold key:
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
      ),

      // attach your real drawer here
      drawer: const DrawerWidget(),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.04, screenWidth * 0.05, screenHeight * 0.03),
          child: subjects.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              children: List.generate(subjects.length, (index) {
                // guard against mismatched color/cardData indices
                final color = cardColors[index % cardColors.length];
                final icon = (index < cardData.length) ? cardData[index]['icon'] as IconData : Icons.book;

                return Column(
                  children: [
                    // Main Card
                    GestureDetector(
                      onTap: () {
                        Get.to(ChapterWiseSyllabus(path: subjectsId[index], title: subjects[index]));
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.04),
                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(4, 0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(icon, size: 18),
                                SizedBox(width: screenWidth * 0.02),
                                Container(
                                  width: screenWidth * 0.55,
                                  child: Text(
                                    subjects[index],
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              isExpanded.length > index && isExpanded[index] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Expandable Content (keeps structure, currently empty)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: (isExpanded.length > index && isExpanded[index]) ? screenHeight * 0.02 : 0, horizontal: screenWidth * 0.04),
                      margin: EdgeInsets.only(bottom: (isExpanded.length > index && isExpanded[index]) ? screenHeight * 0.01 : 0),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, spreadRadius: 2, offset: const Offset(2, 2)),
                      ]),
                      child: (isExpanded.length > index && isExpanded[index] && subjects[index].isNotEmpty)
                          ? const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [SizedBox()],
                      )
                          : const SizedBox(),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
