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

class TopicWiseSyllabusMcq extends StatefulWidget {
  final List<Map<String, dynamic>> pathQuestionList;
  final String? subjectId;

  const TopicWiseSyllabusMcq({
    required this.pathQuestionList,
    this.subjectId,
    super.key,
  });

  @override
  State<TopicWiseSyllabusMcq> createState() => _TopicWiseSyllabusMcqState();
}

class _TopicWiseSyllabusMcqState extends State<TopicWiseSyllabusMcq> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> simple = [];
  List<Map<String, dynamic>> medium = [];
  List<Map<String, dynamic>> complex = [];
  List<Map<String, dynamic>> difficult = [];
  List<Map<String, dynamic>> advanced = [];
  List<Map<String, dynamic>> others = [];

  Set<String> bookmarkedIds = {};
  final Map<String, int> _loadedCount = {}; // Track lazy load per tab
  static const int pageSize = 20;

  @override
  void initState() {
    super.initState();
    getQuestionList();
    loadBookmarks();
  }

  void getQuestionList() {
    for (var question in widget.pathQuestionList) {
      final complexity = (question["complexity"] ?? "").toString().toLowerCase();
      switch (complexity) {
        case "s":
          simple.add(question);
          break;
        case "m":
          medium.add(question);
          break;
        case "c":
          complex.add(question);
          break;
        case "d":
          difficult.add(question);
          break;
        case "a":
          advanced.add(question);
          break;
        default:
          others.add(question);
          break;
      }
    }
    setState(() {});
  }

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    bookmarkedIds = prefs.getStringList('bookmarks')?.toSet() ?? {};
    setState(() {});
  }

  Future<void> toggleBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (bookmarkedIds.contains(id)) {
      bookmarkedIds.remove(id);
    } else {
      bookmarkedIds.add(id);
    }
    await prefs.setStringList('bookmarks', bookmarkedIds.toList());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Tab>[];
    final tabViews = <Widget>[];

    if (simple.isNotEmpty) {
      tabs.add(const Tab(text: "Easy"));
      tabViews.add(_buildQuestionList(simple, "easy"));
    }
    if (medium.isNotEmpty) {
      tabs.add(const Tab(text: "Medium"));
      tabViews.add(_buildQuestionList(medium, "medium"));
    }
    if (complex.isNotEmpty) {
      tabs.add(const Tab(text: "Complex"));
      tabViews.add(_buildQuestionList(complex, "complex"));
    }
    if (difficult.isNotEmpty) {
      tabs.add(const Tab(text: "Difficult"));
      tabViews.add(_buildQuestionList(difficult, "difficult"));
    }
    if (advanced.isNotEmpty) {
      tabs.add(const Tab(text: "Advanced"));
      tabViews.add(_buildQuestionList(advanced, "advanced"));
    }
    if (others.isNotEmpty) {
      tabs.add(const Tab(text: "Theory"));
      tabViews.add(_buildQuestionList(others, "theory"));
    }

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: DrawerWidget(),
        appBar: AppBar(
          title: Text(widget.pathQuestionList[0]["chapter"] ?? ""),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList(List<Map<String, dynamic>> questionList, String key) {
    _loadedCount.putIfAbsent(key, () => pageSize);

    final ScrollController scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          _loadedCount[key] = (_loadedCount[key]! + pageSize)
              .clamp(0, questionList.length);
        });
      }
    });

    final visibleQuestions = questionList.take(_loadedCount[key]!).toList();

    return ListView.builder(
      controller: scrollController,
      itemCount: visibleQuestions.length,
      itemBuilder: (context, index) {
        final question = visibleQuestions[index];
        final questionId = question["question_serial_number"] ?? "q_$index";
        final bookmarked = bookmarkedIds.contains(questionId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MathText(
              expression: question["question"] ?? "",
              height: _estimateHeight(question["question"]),
            ),
            Row(
              children: [
                if ((question["test_answer_string"] != null &&
                    question["test_answer_string"]
                        .toString()
                        .toLowerCase() !=
                        "nr" &&
                    question["test_answer_string"]
                        .toString()
                        .toLowerCase() !=
                        "na") ||
                    (question["description_image_id"]
                        .toString()
                        .toLowerCase() !=
                        "nr" &&
                        question["description_image_id"]
                            .toString()
                            .toLowerCase() !=
                            "na"))
                  TextButton(
                    onPressed: () {
                      final isNR = question["description_image_id"]
                          .toString()
                          .toLowerCase() ==
                          "nr";
                      Get.to(
                            () => TextAnswer(
                          title: widget.pathQuestionList[0]["chapter"] ?? "",
                          imagePath: isNR
                              ? question["test_answer_string"]
                              : question["description_image_id"],
                          basePath: isNR
                              ? "nr"
                              : "/${question["subjectid"]}/images/",
                          stream: question["stream"],
                        ),
                      );
                    },
                    child: const Text("Text Answer"),
                  ),
                if ((question["explaination_video_id"]
                    ?.toString()
                    .toLowerCase() ??
                    "") !=
                    "na" &&
                    (question["explaination_video_id"]
                        ?.toString()
                        .toLowerCase() ??
                        "") !=
                        "nr")
                  TextButton(
                    onPressed: () {
                      Get.to(
                            () => EncryptedVideoPlayer(
                          title: widget.pathQuestionList[0]["chapter"] ?? "",
                          filePath: question["explaination_video_id"],
                          basePath: "${question["subjectid"]}/videos/",
                        ),
                      );
                    },
                    child: const Text("Explanation"),
                  ),
                TextButton(
                  onPressed: () {
                    Get.to(
                          () => NotepadPage(
                        subjectId: widget.subjectId ?? "unknown",
                        chapter: question["chapter"] ?? "chapter",
                      ),
                    );
                  },
                  child: const Text("Notepad"),
                ),
                TextButton(
                  onPressed: () => toggleBookmark(questionId),
                  child: Text(bookmarked ? "Unbookmark" : "Bookmark"),
                ),
              ],
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  double _estimateHeight(String text) {
    if (text.isEmpty) return 60;

    final lines = text.split('\n').length;
    final longLines =
        text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath =
        text.contains(r'\frac') || text.contains(r'\sqrt') || text.contains(r'\(');

    double height = (lines + longLines) * 20.0;

    if (hasComplexMath) height += 40.0;

    return height.clamp(60.0, 200.0);
  }
}
