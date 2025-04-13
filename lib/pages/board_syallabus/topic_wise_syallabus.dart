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
  final Map<String, dynamic> pathQuestion;
  final String? subjectId;

  const TopicWiseSyllabus({required this.pathQuestion, this.subjectId, super.key});

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
    complexity = widget.pathQuestion["complexity"].toString().toLowerCase();
    checkIfBookmarked();
    if (complexity != "na") getQuestionList();
  }

  void checkIfBookmarked() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];
    final currentId = widget.pathQuestion["id"].toString();
    setState(() {
      isBookmarked = bookmarks.contains(currentId);
    });
  }

  void getQuestionList() {
    switch (complexity) {
      case "s": simple.add(widget.pathQuestion); break;
      case "m": medium.add(widget.pathQuestion); break;
      case "c": complex.add(widget.pathQuestion); break;
      case "d": difficult.add(widget.pathQuestion); break;
      case "a": advanced.add(widget.pathQuestion); break;
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

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question["description"] != null)
            MathText(expression: question["description"]),
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
                  Get.to(() => NotepadPage(
                    subjectId: widget.subjectId ?? "unknown",
                    chapter: question["chapter"] ?? "chapter",
                  ));
                },
                child: const Text('Notes'),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}