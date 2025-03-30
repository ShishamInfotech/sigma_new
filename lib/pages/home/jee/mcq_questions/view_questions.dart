import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/pages/home/jee/mcq_questions/simple_questions.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';


class ViewQuestions extends StatefulWidget {
  const ViewQuestions({super.key});

  @override
  State<ViewQuestions> createState() => _ViewQuestionsState();
}

class _ViewQuestionsState extends State<ViewQuestions> {
  final GlobalKey<ScaffoldState> _tablequizscaffoldKey =
  GlobalKey<ScaffoldState>();

  Map<String, dynamic> parsedJson={};
  List<dynamic> sigmaData =[];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getQuestionList();

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

    /*if (widget.pathQuestion!.contains("10")) {
      newPath = "10/";
    } else if (widget.pathQuestion!.contains("12")) {
      newPath = "12/";
    }*/

    var inputFile = await SdCardUtility.getSubjectEncJsonData('${newPath}${board}testseries/.json');


    parsedJson = jsonDecode(inputFile!);

    sigmaData = parsedJson["sigma_data"];
    print("Sig ${parsedJson["sigma_data"][0]["complexity"]}");

    createFinalList();
  }

  Future<void> createFinalList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (true) {
      // Get the stored test level based on subject
      // currentTestLevel = prefs.getString("${widget.jeeData.first.question.trim().toUpperCase()}_LEVEL") ?? "s";

      List<dynamic> simple = [];
      List<dynamic> medium = [];
      List<dynamic> complex = [];
      List<dynamic> difficult = [];
      List<dynamic> advanced = [];

      // Categorize questions by complexity
      for (var data in parsedJson["sigma_data"]) {
        switch (data["complexity"]) {
          case "s":
            simple.add(data);
            print("Simplesss $data");
            break;
          case "m":
            medium.add(data);
            print("Simplessm $data");
            break;
          case "c":
            complex.add(data);
            print("Simplessc $data");
            break;
          case "d":
            difficult.add(data);
            print("Simplessd $data");
            break;
          case "a":
            advanced.add(data);
            print("Simplessa $data");
            break;
        }
      }

      for (int j = 0; j < medium.length; j++) {
        //JeeDatum data = simpleque.get(arraySimple[j]);
        //  data.setArrange(allquestions.size() + 1);
        // allquestions.add(data.getQuestion());
        // finalArr.put(data.getJson());
        // randomList.add(data);

        print(medium.length);
        print("Simple ${medium}  Complexity ${sigmaData[j]["complexity"]}");
      }
      // Select random questions
      List<int> getRandomIndices(int size, int count) {
        if (size == 0) return [];
        List<int> indices = List.generate(size, (i) => i);
        indices.shuffle();
        return indices.take(count.clamp(0, size)).toList();
      }

      // Select based on test level


      // Prepare final JSON structure


      // print("SimpleData ${simple.first}");
      setState(() {});
    }// Refresh UI
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: DrawerWidget(context),
        key: _tablequizscaffoldKey,
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
                      _tablequizscaffoldKey.currentState?.openDrawer();
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
                    "MCQ",
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
                SimpleQuestions(easyQuestion: sigmaData),
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
}
