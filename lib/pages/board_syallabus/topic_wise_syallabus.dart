
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
import '../text_answer/text_answer_jee.dart';

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
    _storeChapterPercentage();
    _subjectPercentage();
  }


  Future<void> _storeChapterPercentage() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if the chapter percentage is already stored
    final storedChapters = prefs.getStringList('completed_chapters') ?? [];
    final subjectName = widget.pathQuestionList[0]["subject"] ?? 'Unknown Subject';
    final chapterNumber = widget.pathQuestionList[0]["chapter_number"].toString();

    // If this chapter hasn't been stored yet
    if (!storedChapters.contains(chapterNumber)) {
      // Get the percentage (assuming it's the same for all questions in the chapter)
      final percentage = widget.pathQuestionList[0]["percentage"]?.toString() ?? "0";
      final target_date = widget.pathQuestionList[0]["target_date"]?.toString() ?? "No Target Date";

      // Store the chapter percentage
      await prefs.setDouble('chapter_${chapterNumber}_percentage', double.parse(percentage));
      await prefs.setString('chapter_${chapterNumber}_target', target_date);

      // Mark this chapter as stored
      storedChapters.add(chapterNumber);
      await prefs.setStringList('completed_chapters', storedChapters);


      print('Stored percentage $percentage for chapter $chapterNumber');
    }
  }

  Future<void> _subjectPercentage() async {
    final prefs = await SharedPreferences.getInstance();

    // Extract subject name and percentage
    final subjectName = widget.pathQuestionList[0]["subject"] ?? "Unknown Subject";
    final percentage = widget.pathQuestionList[0]["percentage"]?.toString() ?? "0";

    // Store the percentage with subject name as key
    await prefs.setDouble('subject_$subjectName', double.parse(percentage));

    print('Stored $percentage% for $subjectName');
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
        drawer: DrawerWidget(),
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

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${index+1}:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  Expanded(child: MathText(expression: question["description"] ?? "", height: _estimateHeight(question["description"]))),
                ],
              ),
              
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
                            Get.to(() => TextAnswerJee(
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
                              title: widget.pathQuestionList[0]["subchapter"] ?? "",
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
          ),
        );
      },
    );
  }

  double _estimateHeight(String text) {
    if (text.isEmpty) return 0;

    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt') || text.contains(r'\(');

    double height = (lines + longLines) * 30.0;
    height = height * 5.0;

    if (hasComplexMath) {
      height += 30.0;
    }

    return height.clamp(50.0, 300.0);
  }
}
