/*
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/pages/text_answer/text_answer.dart';
import 'package:sigma_new/pages/video_explanation/VideoEncrypted.dart';
import 'package:sigma_new/pages/video_explanation/video_explanation.dart';
import 'package:sigma_new/questions/easy_questions.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class TopicWiseSyllabus extends StatefulWidget {
  var pathQuestion;
  String? subjectId;
  TopicWiseSyllabus({required this.pathQuestion,this.subjectId, super.key});

  @override
  State<TopicWiseSyllabus> createState() => _TopicWiseSyllabusState();
}

class _TopicWiseSyllabusState extends State<TopicWiseSyllabus> {
  final GlobalKey<ScaffoldState> _TopicWiseSyllabusscaffoldKey =
      GlobalKey<ScaffoldState>();

  Map<String, dynamic> parsedJson = {};
  List<dynamic> sigmaData = [];
  List<dynamic> simple = [];
  List<dynamic> medium = [];
  List<dynamic> complex = [];
  List<dynamic> difficult = [];
  List<dynamic> advanced = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.pathQuestion["complexity"].toString().toLowerCase() !="na")getQuestionList();
  }


  @override
  Widget build(BuildContext context) {
    print("Path Q ${widget.pathQuestion}");
    double height = MediaQuery.of(context).size.height;

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: DrawerWidget(context),
        key: _TopicWiseSyllabusscaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            (isPortrait) ? height * 0.08 : height * 0.5,
          ),
          child: Stack(
            children: [
              AppBar(
                  // backgroundColor: backgroundColor,
                  leading: InkWell(
                    onTap: () {
                      _TopicWiseSyllabusscaffoldKey.currentState?.openDrawer();
                    },
                    child: const Icon(Icons.menu),
                  ),
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          backgroundColor,
                          backgroundColor,
                          backgroundColor,
                          whiteColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  title: Text(
                    "${widget.pathQuestion["chapter"]}",
                    style: black20w400MediumTextStyle,
                  )),
            ],
          ),
        ),
        body: Column(
          children: [
            height10Space,
            if(widget.pathQuestion["complexity"].toString().toLowerCase() !="na")Padding(
              padding: const EdgeInsets.only(right: 10.0, left: 10.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.06,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white),
                child: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.rectangle,
                  ),
                  padding: const EdgeInsets.all(5),
                  labelPadding: const EdgeInsets.all(5),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: primaryColor,
                  unselectedLabelColor: blackColor,
                  splashBorderRadius: BorderRadius.circular(5),
                  indicatorColor: backgroundColor,
                  tabs: const [
                    Tab(
                      child: Text(
                        "Easy",
                      ),
                    ),
                    Tab(
                      child: Text("Medium"),
                    ),
                    Tab(
                      child: Text("Complex"),
                    ),
                    Tab(
                      child: Text("Difficult"),
                    ),
                    Tab(
                      child: Text("Advance"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            //questionData(),
            Expanded(
              child: TabBarView(children: [
                questionData(),
                if (simple.isNotEmpty) EasyQuestions(easyQuestion: simple),
                if (medium.isNotEmpty) EasyQuestions(easyQuestion: medium),
                if (complex.isNotEmpty) EasyQuestions(easyQuestion: complex),
                if (advanced.isNotEmpty) EasyQuestions(easyQuestion: advanced),
                if (difficult.isNotEmpty) EasyQuestions(easyQuestion: difficult),
              ]),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }


  getQuestionList() async {

    for (var data in widget.pathQuestion) {
      switch (data["complexity"]) {
        case "s":
          simple.add(data);
          break;
        case "m":
          medium.add(data);
          break;
        case "c":
          complex.add(data);
          break;
        case "d":
          difficult.add(data);
          break;
        case "a":
          advanced.add(data);
          break;
      }
    }

    setState(() {});
  }

  Widget questionData() {
    return Column(
      children: [
        Text(widget.pathQuestion["description"]),

        Text(simple.first),
        Row(
          children: [
            if((widget.pathQuestion["test_answer_string"]!=null) &&(widget.pathQuestion["test_answer_string"].toString().toLowerCase()!="nr") || widget.pathQuestion["description_image_id"].toString().toLowerCase()!="nr")
            TextButton(onPressed: () {
              if(widget.pathQuestion["description_image_id"].toString().toLowerCase()=="nr"){

                Get.to(TextAnswer(imagePath: widget.pathQuestion["test_answer_string"], basePath: "nr",));

              }else{
             // Get.to(TextAnswer(imagePath: widget.pathQuestion["description_image_id"],basePath: "/jee/theory/${widget.pathQuestion["subjectid"]}/images/",));
              Get.to(TextAnswer(imagePath: widget.pathQuestion["description_image_id"],basePath: "/${widget.pathQuestion["subjectid"]}/images/",));
              }
            }, child: Text('Text Answer')),

            if ((widget.pathQuestion["explaination_video_id"]
                        .toString()
                        .toLowerCase()) !=
                    "na" &&
                (widget.pathQuestion["explaination_video_id"]
                        .toString()
                        .toLowerCase()) !=
                    "nr")
              TextButton(onPressed: () {

                //Get.to(VideoExplanation(videoPath: widget.pathQuestion["explaination_video_id"],basePath: "/${widget.pathQuestion["subjectid"]}/videos/",));
                Get.to(EncryptedVideoPlayer(filePath: widget.pathQuestion["explaination_video_id"], basePath: "${widget.pathQuestion["subjectid"]}/videos/",));
              }, child: Text('Explanation')),
            TextButton(onPressed: () {}, child: Text('Notes')),
            TextButton(onPressed: () {}, child: Text('Bookmarks'))
          ],
        )
      ],
    );
  }
}
*/


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/pages/text_answer/text_answer.dart';
import 'package:sigma_new/pages/video_explanation/VideoEncrypted.dart';
import 'package:sigma_new/questions/easy_questions.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import '../../math_view/math_text.dart';
import '../notepad/noteswrite.dart';

class TopicWiseSyllabus extends StatefulWidget {
  final Map<String, dynamic> pathQuestion;
  final String? subjectId;

  TopicWiseSyllabus({required this.pathQuestion, this.subjectId, super.key});

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

  bool isBookmarked = false;
  late String complexity;

  @override
  void initState() {
    super.initState();
    checkIfBookmarked();
    complexity = widget.pathQuestion["complexity"].toString().toLowerCase();
    if (complexity != "na") getQuestionList();
  }

  void checkIfBookmarked() async {
    final prefs = await SharedPreferences.getInstance();
    final currentDesc = widget.pathQuestion["description"].toString();
    final bookmarkedData = prefs.getString('bookmarkedQuestions') ?? "{}";
    final Map<String, dynamic> bookmarksMap =
    Map<String, dynamic>.from(jsonDecode(bookmarkedData));

    setState(() {
      isBookmarked = bookmarksMap.containsKey(currentDesc);
    });
  }

  void toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final currentDesc = widget.pathQuestion["description"].toString();

    final bookmarkedData = prefs.getString('bookmarkedQuestions') ?? "{}";
    final Map<String, dynamic> bookmarksMap =
    Map<String, dynamic>.from(jsonDecode(bookmarkedData));

    if (bookmarksMap.containsKey(currentDesc)) {
      bookmarksMap.remove(currentDesc);
      setState(() {
        isBookmarked = false;
      });
    } else {
      bookmarksMap[currentDesc] = widget.pathQuestion;
      setState(() {
        isBookmarked = true;
      });
    }

    await prefs.setString('bookmarkedQuestions', jsonEncode(bookmarksMap));
  }

  void getQuestionList() {
    final complexity =
    (widget.pathQuestion["complexity"] ?? "").toString().toLowerCase();

    switch (complexity) {
      case "s":
        simple.add(widget.pathQuestion);
        break;
      case "m":
        medium.add(widget.pathQuestion);
        break;
      case "c":
        complex.add(widget.pathQuestion);
        break;
      case "d":
        difficult.add(widget.pathQuestion);
        break;
      case "a":
        advanced.add(widget.pathQuestion);
        break;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    List<Tab> tabs = [];
    List<Widget> tabViews = [];

    if (simple.isNotEmpty) {
      tabs.add(const Tab(child: Text("Easy")));
      tabViews.add(_buildQuestionList(simple));
    }
    if (medium.isNotEmpty) {
      tabs.add(const Tab(child: Text("Medium")));
      tabViews.add(_buildQuestionList(medium));
    }
    if (complex.isNotEmpty) {
      tabs.add(const Tab(child: Text("Complex")));
      tabViews.add(_buildQuestionList(complex));
    }
    if (difficult.isNotEmpty) {
      tabs.add(const Tab(child: Text("Difficult")));
      tabViews.add(_buildQuestionList(difficult));
    }
    if (advanced.isNotEmpty) {
      tabs.add(const Tab(child: Text("Advanced")));
      tabViews.add(_buildQuestionList(advanced));
    }

    return complexity == "na"
        ? _buildNoTabScaffold(context, height)
        : DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: DrawerWidget(context),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(isPortrait ? height * 0.08 : height * 0.5),
          child: AppBar(
            leading: InkWell(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: const Icon(Icons.menu),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [backgroundColor, backgroundColor, backgroundColor, whiteColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            title: Text(widget.pathQuestion["chapter"] ?? "", style: black20w400MediumTextStyle),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            if (tabs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: TabBar(
                    tabs: tabs,
                    isScrollable: true,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: primaryColor.withOpacity(0.1),
                    ),
                    labelColor: primaryColor,
                    unselectedLabelColor: blackColor,
                  ),
                ),
              ),
            const SizedBox(height: 15),
            if (tabs.isNotEmpty)
              Expanded(child: TabBarView(children: tabViews)),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTabScaffold(BuildContext context, double height) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerWidget(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(height * 0.08),
        child: AppBar(
          leading: InkWell(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: const Icon(Icons.menu),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [backgroundColor, backgroundColor, backgroundColor, whiteColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          title: Text(widget.pathQuestion["chapter"] ?? "", style: black20w400MediumTextStyle),
        ),
      ),
      body: SingleChildScrollView(child: _buildQuestionCard(widget.pathQuestion)),
    );
  }


  Widget _buildQuestionList(List<Map<String, dynamic>> questionList) {
    return ListView.builder(
      itemCount: questionList.length,
      itemBuilder: (context, index) {
        return _buildQuestionCard(questionList[index]);
      },
    );
  }

  Widget  _buildQuestionCard(Map<String, dynamic> question){
    return Column(
      children: [
        if (question["description"] != null)
          MathText(expression: question["description"], height: estimateHeight(question["description"])),
        Row(
          children: [
            if ((question["test_answer_string"] != null &&
                question["test_answer_string"].toString().toLowerCase() != "nr") ||
                question["description_image_id"].toString().toLowerCase() != "nr")
              TextButton(
                onPressed: () {
                  final isNR = question["description_image_id"].toString().toLowerCase() == "nr";
                  Get.to(() => TextAnswer(
                    imagePath: isNR ? question["test_answer_string"] : question["description_image_id"],
                    basePath: isNR ? "nr" : "/${question["subjectid"]}/images/",
                  ));
                },
                child: const Text('Text Answer'),
              ),
            if ((question["explaination_video_id"]?.toString().toLowerCase() ?? "") != "na" &&
                (question["explaination_video_id"]?.toString().toLowerCase() ?? "") != "nr")
              TextButton(
                onPressed: () {
                  Get.to(() => EncryptedVideoPlayer(
                    filePath: question["explaination_video_id"],
                    basePath: "${question["subjectid"]}/videos/",
                  ));
                },
                child: const Text('Explanation'),
              ),
            TextButton(
                onPressed: () {
                  Get.to(NotepadPage(
                    subjectId: widget.subjectId ?? "unknown",
                    chapter: question["chapter"] ?? "chapter",
                  ));
                },
                child: const Text('Notes')),
            TextButton(
                onPressed: toggleBookmark,
                child: Text(isBookmarked ? 'Unbookmark' : 'Bookmark')),
          ],
        )
      ],
    );
  }




  double estimateHeight(String text) {
    final lines = (text.length / 30).ceil(); // assume 30 chars per line
    return lines * 40.0; // assume each line is about 40 pixels tall
  }

}
