import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/questions/easy_questions.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class TopicWiseSyllabus extends StatefulWidget {
  var pathQuestion;

  TopicWiseSyllabus({required this.pathQuestion,super.key  });

  @override
  State<TopicWiseSyllabus> createState() => _TopicWiseSyllabusState();
}

class _TopicWiseSyllabusState extends State<TopicWiseSyllabus> {
  final GlobalKey<ScaffoldState> _TopicWiseSyllabusscaffoldKey =
  GlobalKey<ScaffoldState>();

  Map<String, dynamic> parsedJson={};
  List<dynamic> sigmaData =[];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //getQuestionList();

  }


  getQuestionList() async{

    var newPath;
    var board;
    final prefs = await SharedPreferences.getInstance();
    String? course = prefs.getString('course');
    print(
        "Standard${prefs.getString('standard')} State:${prefs.getString('board')}");

    if (prefs.getString('board') == "Maharashtra") {
      board = "MH/";
    } else {
      board = prefs.getString('board');
    }

    if (widget.pathQuestion!.contains("10")) {
      newPath = "10/";
    } else if (widget.pathQuestion!.contains("12")) {
      newPath = "12/";
    }

    var inputFile = await SdCardUtility.getSubjectEncJsonData('${newPath}${board}testseries/${widget.pathQuestion}.json');


    parsedJson = jsonDecode(inputFile!);

    sigmaData = parsedJson["sigma_data"];
    print("Sig ${parsedJson["sigma_data"][0]["complexity"]}");

    //createFinalList();
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
                    "Std",
                    style: black20w400MediumTextStyle,
                  )),
            ],
          ),
        ),
        body: Column(
          children: [
            height10Space,
            Padding(
              padding: const EdgeInsets.only(right: 65.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
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
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
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


  Widget questionData(){
    return Column(
      children: [
        Text(widget.pathQuestion["description"]),
        Row(
          children: [
            TextButton(onPressed: (){}, child: Text('Text Answer')),
            TextButton(onPressed: (){}, child: Text('Explanation')),
            TextButton(onPressed: (){}, child: Text('Notes')),
            TextButton(onPressed: (){}, child: Text('Bookmarks'))

          ],
        )
      ],
    );
  }

}
