import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sigma_new/models/menu_models.dart';
import 'package:sigma_new/pages/home/jee/jee_neet_concept.dart';
import 'package:sigma_new/pages/home/jee/jee_neet_mcq.dart';
import 'package:sigma_new/pages/home/jee/mock_exam/jeemockexam.dart';
import 'package:sigma_new/pages/last_minute_revision/last_minute_revision_mcq.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

import '../../drawer/drawer.dart';
import '../../last_minute_revision/last_minute_revision.dart';
import 'mock_exam/MockExamInstructions.dart';
import 'mock_exam/MockExamScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JeeSubjectwise extends StatefulWidget {
  String path;
  final String? complexity;
  final bool isConcept;
  String? complex;

  JeeSubjectwise({
    required this.path,
    this.complexity,
    this.isConcept = false,
    this.complex,
    super.key
  });

  @override
  State<JeeSubjectwise> createState() => _JeeSubjectwiseState();
}

class _JeeSubjectwiseState extends State<JeeSubjectwise> {
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
        navigation: () {},
        title: 'Chemistry'),
    Menu(
        color: 0xFFF8D9C4,
        imagePath: 'assets/svg/quickguideimg.svg',
        navigation: () {},
        title: 'Biology'),
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
        navigation: () {},
        title: 'Chemistry'),
    Menu(
        color: 0xFFF8D9C4,
        imagePath: 'assets/svg/quickguideimg.svg',
        navigation: () {},
        title: 'Biology'),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    subjectWiseTest();
  }


  // Use a scaffold key to open drawer from AppBar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> subjects = [];
  List<String> subjectsTopic = [];
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

  // subjectWiseTest() async {
  //   var newPath;
  //   var board;
  //   // final prefs = await SharedPreferences.getInstance();
  //   // String? course = prefs.getString('course');
  //
  //   if (widget.path.contains("Concept")) {
  //     newPath = "/THEORY";
  //   } else {
  //     newPath = "/MCQ";
  //   }
  //
  //   var inputFile = await SdCardUtility.getSubjectEncJsonData(
  //       'JEE$newPath/sigma_data.json');
  //
  //   print("INput File  $inputFile");
  //   Map<String, dynamic> parsedJson = jsonDecode(inputFile!);
  //   // Extracting subject values
  //   List<dynamic> sigmaData = parsedJson["sigma_data"];
  //
  //   subjects = sigmaData.map((data) => data["subject"].toString()).toList();
  //   subjectsId = sigmaData.map((data) => data["subjectid"].toString()).toList();
  //   // Get all subjects
  //
  //   if (!widget.path.contains("Concept")) {
  //     for (int i = 0; i < subjects.length; i++) {
  //       if (widget.path.removeAllWhitespace
  //               .toLowerCase()
  //               .contains("multiplechoicequestion") &&
  //           !subjects[i].contains("Offline") &&
  //           !subjects[i].contains("Mock")) {
  //         subjectsTopic.add(subjects[i]);
  //       }
  //
  //       if (widget.path.removeAllWhitespace
  //               .toLowerCase()
  //               .contains("subjectwiseexam") &&
  //           subjects[i].contains("Offline")) {
  //         subjectsTopic.add(subjects[i]);
  //       }
  //
  //       if (widget.path.removeAllWhitespace
  //               .toLowerCase()
  //               .contains("mockexam") &&
  //           subjects[i].contains("Mock")) {
  //         subjectsTopic.add(subjects[i]);
  //       }
  //     }
  //   } else {
  //     subjectsTopic = subjects;
  //   }
  //
  //   //removeTestSeriesFromSubjectTitle(subjects);
  //
  //   // Print subjects
  //   print(subjects);
  //   setState(() {});
  // }

  subjectWiseTest() async {
    var newPath;

    if (widget.path.contains("Concept")) {
      newPath = "/THEORY";
    } else {
      newPath = "/MCQ";
    }

    var inputFile = await SdCardUtility.getSubjectEncJsonData(
        'JEE$newPath/sigma_data.json');

    Map<String, dynamic> parsedJson = jsonDecode(inputFile!);
    List<dynamic> sigmaData = parsedJson["sigma_data"];

    // Apply complexity filter if it exists
    if (widget.complexity != null) {
      sigmaData = sigmaData.where((data) =>
      data["complexity"]?.toString().toLowerCase() == widget.complexity!.toLowerCase()
      ).toList();
    }

    subjects = sigmaData.map((data) => data["subject"].toString()).toList();
    subjectsId = sigmaData.map((data) => data["subjectid"].toString()).toList();

    if (!widget.path.contains("Concept")) {
      // Existing filtering logic for non-concept paths
      for (int i = 0; i < subjects.length; i++) {
        if (widget.path.removeAllWhitespace
            .toLowerCase()
            .contains("multiplechoicequestion") &&
            !subjects[i].contains("Offline") &&
            !subjects[i].contains("Mock")) {
          subjectsTopic.add(subjects[i]);
        }
        // ... rest of your existing filtering logic
        if (widget.path.removeAllWhitespace
                .toLowerCase()
                .contains("subjectwiseexam") &&
            subjects[i].contains("Offline")) {
          subjectsTopic.add(subjects[i]);
        }

        if (widget.path.removeAllWhitespace
                .toLowerCase()
                .contains("mockexam") &&
            subjects[i].contains("Mock")) {
          subjectsTopic.add(subjects[i]);
        }
      }
    } else {
      subjectsTopic = subjects;
    }

    setState(() {});
  }

  Future<Map<String, List<Map<String, dynamic>>>> readMockAttemptsFromSDCard() async {
    try {
      final directory = await SdCardUtility.getBasePath();
      final filePath = '$directory/jee_exam_attempt.json';
      final file = File(filePath);

      if (!await file.exists()) return {};

      final content = await file.readAsString();
      if (content.trim().isEmpty) return {};

      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) return {};

      Map<String, List<Map<String, dynamic>>> parsedData = {};

      decoded.forEach((key, value) {
        if (value is List) {
          parsedData[key] = value.whereType<Map<String, dynamic>>().toList();
        }
      });

      // Sort by latest date
      parsedData.forEach((key, list) {
        list.sort((a, b) {
          final da = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
          final db = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
          return db.compareTo(da);
        });
      });

      return parsedData;
    } catch (e) {
      print("Error reading SD attempts: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> getCurrentExamLevelInfo(bool isPCB) async {
    final data = await readMockAttemptsFromSDCard();

    final all = data.values.expand((e) => e).toList();

    final attempts = all.where((a) => a['isPCB'] == isPCB).toList();

    if (attempts.isEmpty) {
      return {
        "level": "Simple",
        "tag": "s",
        "average": 0.0,
        "attempts": 0
      };
    }

    final latest = attempts.first;

    final tag = latest['level']?.toString().toLowerCase() ?? "s";

    final levelName = {
      's': 'Simple',
      'm': 'Medium',
      'c': 'Complex',
      'd': 'Difficult',
      'a': 'Advance',
    }[tag] ?? "Simple";

    final scores = attempts.map((a) {
      final s = a['score'];
      return s is String ? double.tryParse(s) ?? 0 : (s as num).toDouble();
    }).toList();

    final avg = scores.reduce((a, b) => a + b) / scores.length;

    return {
      "level": levelName,
      "tag": tag,
      "average": avg,
      "attempts": attempts.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    print("Subject ${widget.path}");
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      bottomNavigationBar: widget.path.toString().toLowerCase() ==
                  "multiple choice question" ||
              widget.path.toString().toLowerCase() == "concept"
          ? InkWell(
              onTap: () {
                if (widget.path.toString().toLowerCase() == "concept") {
                  Get.to(LastMinuteRevision(
                    path: "JEE/",
                  ));
                } else {
                  Get.to(LastMinuteRevisionMcq(
                    path: "JEE/MCQ/",
                  ));
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                    color: primaryColor,
                    boxShadow: const [
                      BoxShadow(
                        color: whiteColor,
                      )
                    ],
                    borderRadius: BorderRadius.circular(10)),
                height: 60,
                alignment: Alignment.center,
                child: const Text(
                  'Last Minute Revision',
                  style:
                      TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : Container(
              height: 10,
            ),
      appBar: AppBar(
          // backgroundColor: backgroundColor,
          leading: InkWell(
            onTap: () {
              print("Opening Drawer");
              _scaffoldKey.currentState?.openDrawer();
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
            widget.path,
            style: black20w400MediumTextStyle,
          )),
      // <-- here we attach your existing drawer implementation
      drawer: const DrawerWidget(),

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
                  itemCount: subjectsTopic.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            if (widget.isConcept) {
                              // Directly navigate to JeeNeetConcept with the selected complexity
                              Get.to(JeeNeetConcept(
                                subjectId: subjectsId[index],
                                complexity: widget.complexity, // Use the already selected complexity
                                title: subjectsTopic[index],
                              ));
                            } else
                            if (examPreparationMenu[index].navigation != null) {
                              examPreparationMenu[index].navigation!();
                              if (widget.path.removeAllWhitespace
                                      .toLowerCase()
                                      .contains("multiplechoicequestion") ||
                                  widget.path.removeAllWhitespace
                                      .toLowerCase()
                                      .contains("subjectwiseexam")) {
                                Get.to(JeeNeetMcq(
                                  title: subjectsTopic[index],
                                  subjectId: subjectsId[index],
                                ));
                              } else if (widget.path.removeAllWhitespace
                                  .toLowerCase()
                                  .contains("concept")) {
                                if(widget.complex=="e"){
                                  Get.to(JeeNeetConcept(
                                    subjectId: subjectsId[index],
                                    complexity: "e",
                                    title: subjects[index],
                                  ));
                                }else{
                                  Get.to(JeeNeetConcept(
                                    subjectId: subjectsId[index],
                                    complexity: "a",
                                    title: subjects[index],
                                  ));
                                }
                                // Get.to(JeeNeetConcept(subjectId: subjectsId[index],));
                              } else if (widget.path.removeAllWhitespace
                                  .toLowerCase()
                                  .contains("mockexam")) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return FutureBuilder<Map<String, dynamic>>(
                                      future: getCurrentExamLevelInfo(
                                          subjectsTopic[index].toLowerCase().contains("pcb")),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return AlertDialog(
                                            title: const Text("Exam information"),
                                            content: const Text("Loading..."),
                                          );
                                        }

                                        final info = snapshot.data!;
                                        final level = info["level"];
                                        final avg = info["average"];
                                        final attempts = info["attempts"];
                                        final tag = info["tag"];

                                        return AlertDialog(
                                          title: const Text(
                                            'Exam Information',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20, // Increased size
                                            ),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                    fontSize: 16,              // ⬅ Bigger base font
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  children: [

                                                    const TextSpan(text: "Your Current Test Average: "),
                                                    TextSpan(
                                                      text: "${avg.toStringAsFixed(2)}%",
                                                      style: TextStyle(
                                                        color: avg >= 70 ? Colors.green : Colors.red,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,          // ⬅ Larger highlight text
                                                      ),
                                                    ),

                                                    const TextSpan(text: "\n\n"),

                                                    const TextSpan(text: "Current Test Level Qualified for: "),
                                                    TextSpan(
                                                      text: level.toUpperCase(),
                                                      style: const TextStyle(
                                                        color: Colors.blueAccent,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,          // ⬅ Larger highlight text
                                                      ),
                                                    ),

                                                    const TextSpan(text: "\n\n"),

                                                    const TextSpan(text: "Total Attempts: "),
                                                    TextSpan(
                                                      text: attempts.toString(),
                                                      style: const TextStyle(
                                                        color: Colors.purple,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,          // ⬅ Larger highlight text
                                                      ),
                                                    ),

                                                    const TextSpan(text: "\n\nBegin Test?"),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text(
                                                'Yes',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                instructionMockExam(subjectsId[index], subjectsTopic[index]);
                                              },
                                            ),
                                            TextButton(
                                              child: const Text(
                                                'No',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              onPressed: () => Navigator.of(context).pop(),
                                            ),
                                          ],
                                        );


                                      },
                                    );
                                  },
                                );

                              }
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
                          removeTestSeriesFromSubjectTitle(
                              subjectsTopic[index]),
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


  /*instructionMockExam(String subjectId, String title) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Exam information'),
            content: const Text(
              '1. The group consists of Physics, Chemistry and Mathematics.\n2. The duration of the examination will be 120 minutes.\n3. You need to attempt all the 198 Multi-Choice Questions.\n4. The mock examination consists of 50 questions each from Physics and Chemistry, 98 questions from Mathematics.\n5. All the questions in level-1 mock examination will appear from simple category questions bank.\n6. You need to score 70% and more marks in each of the 50 consecutive examinations to qualify for the next level.\n7. In case, you want to leave the examination due to some unavoidable situation, the same examination will continue for the remaining time. You will not be able to attempt the next examination.\n8. All your attempted examinations will be saved in the Evaluation bucket to enable to monitor your average score.\n9. You will also be able to evaluate each and every attempted examination question by question in the Evaluation bucket.',
              style: black14BoldTextStyleInter,
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge),
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.to(MockExamScreen(
                    subjectId: subjectId,
                    title: title,
                    path: 'JEE/MCQ/sigma_data.json',
                  ));
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge),
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }*/
  Future<void> instructionMockExam(String subjectId, String title) async {
    // Determine if this is PCB (Biology) or PCM (Mathematics)
    bool isPCB = title.toLowerCase().contains('pcb');


    // Call the new function with all required parameters
    showMockExamInstructions(context, subjectId, title, isPCB);

  }



  final levelNames = {
    's': 'Simple',
    'm': 'Medium',
    'c': 'Complex',
    'd': 'Difficult',
    'a': 'Advanced',
  };

  void showMockExamInstructions(BuildContext context, String subjectId, String title, bool isPCB) async {
    final currentLevel = await getCurrentExamLevelInfo(isPCB);
    final instructions = MockExamInstructions.instructions[currentLevel["tag"]]?[isPCB] ?? 'No instructions available.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Level ${levelNames[currentLevel["tag"]] ?? currentLevel["tag"].toUpperCase()} Instructions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(child: Text(instructions)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge),
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop();
              Get.to(() => MockExamScreen(
                subjectId: subjectId,
                title: title,
                path: 'JEE/MCQ/sigma_data.json',
                  isPCB: isPCB
              ));
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge),
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
