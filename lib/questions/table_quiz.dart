import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/questions/easy_questions.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class TableQuiz extends StatefulWidget {
  String pathQuestion;
  String title;
  TableQuiz({required this.pathQuestion, required this.title, super.key});

  @override
  State<TableQuiz> createState() => _TableQuizState();
}

class _TableQuizState extends State<TableQuiz> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _tablequizscaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic> parsedJson = {};
  List<dynamic> sigmaData = [];

  List<dynamic> simple = [];
  List<dynamic> medium = [];
  List<dynamic> complex = [];
  List<dynamic> difficult = [];
  List<dynamic> advanced = [];

  @override
  void initState() {
    super.initState();
    getQuestionList();
  }

  getQuestionList() async {
    var newPath;
    var board;
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString('board') == "Maharashtra") {
      board = "MH/";
    } else {
      board = prefs.getString('board');
    }

    if (widget.pathQuestion.contains("10")) {
      newPath = "10/";
    } else if (widget.pathQuestion.contains("12")) {
      newPath = "12/";
    }

    var inputFile = await SdCardUtility.getSubjectEncJsonData('${newPath}${board}testseries/${widget.pathQuestion}.json');
    parsedJson = jsonDecode(inputFile!);
    sigmaData = parsedJson["sigma_data"];

    for (var data in sigmaData) {
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

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return DefaultTabController(
      length: [simple, medium, complex, advanced, difficult].where((list) => list.isNotEmpty).length,
      child: Scaffold(
        drawer: DrawerWidget(context),
        key: _tablequizscaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            (isPortrait) ? height * 0.13 : height * 0.5,
          ),
          child: Stack(
            children: [
              AppBar(
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
                  widget.title,
                  style: black20w400MediumTextStyle,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: Get.width * 0.95,
                height: Get.height * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: TabBar(
                  isScrollable: true,
                  indicator: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xFFE0E0E0),
                  ),
                  tabs: [
                    if (simple.isNotEmpty) Tab(child: Text("Easy")),
                    if (medium.isNotEmpty) Tab(child: Text("Medium")),
                    if (complex.isNotEmpty) Tab(child: Text("Complex")),
                    if (advanced.isNotEmpty) Tab(child: Text("Advance")),
                    if (difficult.isNotEmpty) Tab(child: Text("Difficult")),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: TabBarView(
                children: [
                  if (simple.isNotEmpty) EasyQuestions(easyQuestion: simple),
                  if (medium.isNotEmpty) EasyQuestions(easyQuestion: medium),
                  if (complex.isNotEmpty) EasyQuestions(easyQuestion: complex),
                  if (advanced.isNotEmpty) EasyQuestions(easyQuestion: advanced),
                  if (difficult.isNotEmpty) EasyQuestions(easyQuestion: difficult),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
