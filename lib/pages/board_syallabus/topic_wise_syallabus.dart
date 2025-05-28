
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/pages/text_answer/text_answer.dart';
import 'package:sigma_new/pages/video_explanation/VideoEncrypted.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import '../../math_view/math_text.dart';
import '../notepad/noteswrite.dart';

class TopicWiseSyllabus extends StatefulWidget {
  //final List<Map<String, dynamic>> pathQuestionList;
  var pathQuestionList;
  final String? subjectId;

  TopicWiseSyllabus({required this.pathQuestionList, this.subjectId, super.key});

  @override
  State<TopicWiseSyllabus> createState() => _TopicWiseSyllabusState();
}

class _TopicWiseSyllabusState extends State<TopicWiseSyllabus> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> simple = [];
  List<Map<String, dynamic>> medium = [];
  List<Map<String, dynamic>> complex = [];
  List<Map<String, dynamic>> difficult = [];
  List<Map<String, dynamic>> advanced = [];
  List<Map<String, dynamic>> others= [];



  @override
  void initState() {
    super.initState();



    getQuestionList();
  }

  void getQuestionList() {
    print("Questions----------"+ widget.pathQuestionList.toString());

     for(var question in widget.pathQuestionList) {
      final complexity = (question["complexity"] ?? "").toString().toLowerCase();
      switch (complexity) {
      case "s": simple.add(question); break;
      case "m": medium.add(question); break;
      case "c": complex.add(question); break;
      case "d": difficult.add(question); break;
      case "a": advanced.add(question); break;
      default: others.add(question);break;
      }
    }
    setState(() {});
  }

  Future<bool> isBookmarked(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarked = prefs.getStringList('bookmarks') ?? [];
    print("BOOKMARKS ${bookmarked}");
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

  @override
  Widget build(BuildContext context) {
    final tabs = <Tab>[];
    final tabViews = <Widget>[];

    if (simple.isNotEmpty) {
      tabs.add(const Tab(text: "Easy"));
      tabViews.add(_buildQuestionList(simple));
    }
    if (medium.isNotEmpty) {
      tabs.add(const Tab(text: "Medium"));
      tabViews.add(_buildQuestionList(medium));
    }
    if (complex.isNotEmpty) {
      tabs.add(const Tab(text: "Complex"));
      tabViews.add(_buildQuestionList(complex));
    }
    if (difficult.isNotEmpty) {
      tabs.add(const Tab(text: "Difficult"));
      tabViews.add(_buildQuestionList(difficult));
    }
    if (advanced.isNotEmpty) {
      tabs.add(const Tab(text: "Advanced"));
      tabViews.add(_buildQuestionList(advanced));
    }
    if (others.isNotEmpty) {
      tabs.add(const Tab(text: "Theory"));
      tabViews.add(_buildQuestionList(others));
    }


    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: DrawerWidget(context),
        appBar: AppBar(
          title: Text("${widget.pathQuestionList[0]["chapter"]} : ${widget.pathQuestionList[0]["subchapter"]} " ?? ""),
        ),
        body: Column(
          children: [
            if (tabs.isNotEmpty)
              TabBar(
                tabs: tabs,
                isScrollable: true,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.black,
              ),
            Expanded(
              child: TabBarView(children: tabViews),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList(List<Map<String, dynamic>> questionList) {
    return ListView.builder(
      itemCount: questionList.length,
      itemBuilder: (context, index) {
        final question = questionList[index];
        final questionId = question["question_serial_number"] ?? "q_$index";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MathText(expression: question["description"] ?? "", height: estimateHeight(question["description"])),
            FutureBuilder<bool>(
              future: isBookmarked(questionId),
              builder: (context, snapshot) {
                final bookmarked = snapshot.data ?? false;
                return Row(
                  children: [
                    if ((question["test_answer_string"] != null &&
                        question["test_answer_string"].toString().toLowerCase() != "nr" && question["test_answer_string"].toString().toLowerCase() != "na") ||
                (question["description_image_id"].toString().toLowerCase() != "nr" && question["description_image_id"].toString().toLowerCase() != "na"))
                      TextButton(
                        onPressed: () {
                          final isNR = question["description_image_id"].toString().toLowerCase() == "nr";
                          Get.to(() => TextAnswer(
                            title: widget.pathQuestionList[0]["chapter"] ?? "",
                            imagePath: isNR ? question["test_answer_string"] : question["description_image_id"],
                            basePath: isNR ? "nr" : "/${question["subjectid"]}/images/",
                            stream: question["stream"],
                          ));
                        },
                        child: const Text("Text Answer"),
                      ),
                    if ((question["explaination_video_id"]?.toString().toLowerCase() ?? "") != "na" &&
                        (question["explaination_video_id"]?.toString().toLowerCase() ?? "") != "nr")
                      TextButton(
                        onPressed: () {
                          Get.to(() => EncryptedVideoPlayer(
                            title: widget.pathQuestionList[0]["chapter"] ?? "",
                            filePath: question["explaination_video_id"],
                            basePath: "${question["subjectid"]}/videos/",
                          ));
                        },
                        child: const Text("Explanation"),
                      ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => NotepadPage(
                          subjectId: widget.subjectId ?? "unknown",
                          chapter: question["chapter"] ?? "chapter",
                        ));
                      },
                      child: const Text("Notepad"),
                    ),
                    TextButton(
                      onPressed: () => toggleBookmark(questionId),
                      child: Text(bookmarked ? "Unbookmark" : "Bookmark"),
                    ),
                  ],
                );
              },
            ),
            const Divider()
          ],
        );
      },
    );
  }

  double estimateHeight(String text) {
    final lines = (text.length / 30).ceil(); // assume 30 chars per line
    return lines * 40.0; // assume each line is about 40 pixels tall
  }
}
