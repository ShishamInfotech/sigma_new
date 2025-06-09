import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sigma_new/models/menu_models.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/pages/home/jee/jee_subjectwise.dart';
import 'package:sigma_new/ui_helper/constant.dart';

  class JeeNeetHome extends StatefulWidget {
  const JeeNeetHome({super.key});

  @override
  State<JeeNeetHome> createState() => _JeeNeetHomeState();
}

class _JeeNeetHomeState extends State<JeeNeetHome> {
  final GlobalKey<ScaffoldState> _examscaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    List<Menu> examPreparationMenu = [
      Menu(
          color: 0xFFF2C6DF,
          imagePath: 'assets/svg/concept.svg',
          navigation: () {},
          title: 'Concept'),
      Menu(
          color: 0xFFC5DEF2, // Corrected color code
          imagePath: 'assets/svg/mcq_questions.svg',
          navigation: () {},
          title: 'Multiple Choice Question'),
      Menu(
          color: 0xFFC9E4DF,
          imagePath: 'assets/svg/subject_wise_test.svg',
          navigation: () {},
          title: 'Subject Wise Exam'),
      Menu(
          color: 0xFFDBCDF0,
          imagePath: 'assets/svg/mock_test.svg',
          navigation: () {},
          title: 'Mock Exam'),

    ];

    return Scaffold(
      key: _examscaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
          // backgroundColor: backgroundColor,
          leading: InkWell(
            onTap: () {
              print("Opening Drawer");
              _examscaffoldKey.currentState?.openDrawer();
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
          title:const Text(
            "JEE-CET-NEET",
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
                    crossAxisSpacing: 9,
                    mainAxisSpacing: 9,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: examPreparationMenu.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            if (examPreparationMenu[index].navigation != null) {
                              examPreparationMenu[index].navigation!();
                              Get.to(JeeSubjectwise(path: examPreparationMenu[index].title,));
                            }else{
                              print(
                                  'No navigation route defined for this menu item');
                            }
                            // Navigation logic here
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.13,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(examPreparationMenu[index].color),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SvgPicture.asset(
                                examPreparationMenu[index]
                                    .imagePath, // Correct interpolation
                                height: height * 0.07,
                                width: width * 0.07,
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
                          examPreparationMenu[index].title,
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
      drawer: DrawerWidget(),
    );
  }
}
