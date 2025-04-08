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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //getQuestionList();
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
                //  MediumQuestions(),
                //  ComplexQuestions()
              ]),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget questionData() {
    return Column(
      children: [
        Text(widget.pathQuestion["description"]),

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
