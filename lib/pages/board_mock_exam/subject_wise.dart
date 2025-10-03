import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/models/menu_models.dart';
import 'package:sigma_new/questions/table_quiz.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class SubjectWise extends StatefulWidget {
  final String? path;
  const SubjectWise({this.path, super.key});

  @override
  State<SubjectWise> createState() => _SubjectWiseState();
}

class _SubjectWiseState extends State<SubjectWise> {
  List<Menu> examPreparationMenu = [
    Menu(color: 0xFFF2C6DF, imagePath: 'assets/svg/quickguideimg.svg', title: 'Maths'),
    Menu(color: 0xFFC5DEF2, imagePath: 'assets/svg/quickguideimg.svg', title: 'Physics'),
    Menu(color: 0xFFC9E4DF, imagePath: 'assets/svg/quickguideimg.svg', title: 'Chemistry'),
    Menu(color: 0xFFF8D9C4, imagePath: 'assets/svg/quickguideimg.svg', title: 'Biology'),
    Menu(color: 0xFFF2C6DF, imagePath: 'assets/svg/quickguideimg.svg', title: 'Maths'),
    Menu(color: 0xFFC5DEF2, imagePath: 'assets/svg/quickguideimg.svg', title: 'Physics'),
    Menu(color: 0xFFC9E4DF, imagePath: 'assets/svg/quickguideimg.svg', title: 'Chemistry'),
    Menu(color: 0xFFF8D9C4, imagePath: 'assets/svg/quickguideimg.svg', title: 'Biology'),
  ];

  List<String> subjects = [];
  List<String> subjectsId = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    subjectWiseTest();
  }


  String removeTestSeriesFromSubjectTitle(String title) {
    if (title.toLowerCase().contains("test series")) {
      List<String> parts = title.split("-");
      if (parts.length > 1) {
        return "Board Mock Exam - ${parts[1].trim()}";
      }
    }
    return title;
  }

  Future<void> subjectWiseTest() async {
    try {
      String? board;
      String newPath;
      final prefs = await SharedPreferences.getInstance();

      String? boardPref = prefs.getString('board');
      board = (boardPref != null && boardPref == "Maharashtra")
          ? "MH/"
          : "${boardPref ?? ""}/";

      if (widget.path!.contains("10")) {
        newPath = "10/";
      } else if (widget.path!.contains("12")) {
        newPath = "12/";
      } else {
        newPath = "";
      }

      var inputFile = await SdCardUtility.getSubjectEncJsonData(
          '${newPath}${board}testseries/sigma_data.json');

      if (inputFile != null) {
        Map<String, dynamic> parsedJson = jsonDecode(inputFile);
        List<dynamic> sigmaData = parsedJson["sigma_data"];

        setState(() {
          subjects = sigmaData.map((data) => data["subject"].toString()).toList();
          subjectsId = sigmaData.map((data) => data["subjectid"].toString()).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No subject data found")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error loading subjects: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load subjects")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
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
        title: const Text("Board Mock", style: black20w400MediumTextStyle),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: height * 0.8,
                width: width * 0.85,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 0,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: subjects.length,
                  itemBuilder: (BuildContext context, int index) {
                    print("Subjetc Inxdex ${subjects[index]}");
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(
                              TableQuiz(
                                pathQuestion: subjectsId[index],
                                title: removeTestSeriesFromSubjectTitle(subjects[index]),
                              ),
                            );
                          },
                          child: Container(
                            height: height * 0.13,
                            width: width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(examPreparationMenu[index % examPreparationMenu.length].color),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SvgPicture.asset(
                                examPreparationMenu[index % examPreparationMenu.length].imagePath,
                                height: height * 0.08,
                                width: width * 0.08,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          textAlign: TextAlign.center,
                          removeTestSeriesFromSubjectTitle(subjects[index]),
                          style: black14RegularTextStyle,
                        ),
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