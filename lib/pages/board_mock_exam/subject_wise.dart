import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sigma_new/models/menu_models.dart';
import 'package:sigma_new/questions/table_quiz.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class SubjectWise extends StatefulWidget {
  String? path;
  SubjectWise({this.path, super.key});

  @override
  State<SubjectWise> createState() => _SubjectWiseState();
}

class _SubjectWiseState extends State<SubjectWise> {
  List<Menu> examPreparationMenu = [
    Menu(
        color: 0xFFF2C6DF,
        imagePath: 'assets/svg/quickguideimg.svg',
        navigation: () {},
        title: 'Maths'),
    Menu(
        color: 0xFFC5DEF2,
        imagePath: 'assets/svg/quickguideimg.svg',
        navigation: () {},
        title: 'Physics'),
    Menu(
        color: 0xFFC9E4DF, // Corrected color code
        imagePath: 'assets/svg/quickguideimg.svg',
        navigation: (){},
        title: 'Chemistry'),
    Menu(
        color: 0xFFF8D9C4,
        imagePath: 'assets/svg/quickguideimg.svg',
        navigation: (){},
        title: 'Biology'),
  ];

  @override
  void initState() {
    // TODO: implement initState
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
    var inputFile =
        await SdCardUtility.getSubjectEncJsonData('/sigma_data.json');

    print("INput File  $inputFile");
    Map<String, dynamic> parsedJson = jsonDecode(inputFile!);
    // Extracting subject values
    List<dynamic> sigmaData = parsedJson["sigma_data"];

    // Get all subjects
    subjects = sigmaData.map((data) => data["subject"].toString()).toList();
    subjectsId = sigmaData.map((data) => data["subjectid"].toString()).toList();

    //removeTestSeriesFromSubjectTitle(subjects);

    // Print subjects
    print(subjects);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    print(widget.path);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          // backgroundColor: backgroundColor,
          leading: InkWell(
            onTap: () {
              print("Opening Drawer");
              // _quickquidescaffoldKey.currentState?.openDrawer();
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
          title: const Text(
            "Board Mock",
            style: black20w400MediumTextStyle,
          )),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.85,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 0,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: subjects.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            if (examPreparationMenu[index].navigation != null) {
                              examPreparationMenu[index].navigation!();

                              Get.to(TableQuiz(
                                pathQuestion: subjectsId[index],
                                title: removeTestSeriesFromSubjectTitle(
                                    subjects[index]),
                              ));
                            } else {
                              print(
                                  'No navigation route defined for this menu item');
                            }
                          },
                          child: Container(
                            height: height * 0.13,
                            width: width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(examPreparationMenu[index].color),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SvgPicture.asset(
                                examPreparationMenu[index]
                                    .imagePath, // Correct interpolation
                                height: height * 0.08,
                                width: width * 0.08,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          removeTestSeriesFromSubjectTitle(subjects[index]),
                          style: black14RegularTextStyle,
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
