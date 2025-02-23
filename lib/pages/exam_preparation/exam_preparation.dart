import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../models/menu_models.dart';
import '../../ui_helper/constant.dart';
import '../drawer/drawer.dart';

class ExamPreparation extends StatefulWidget {
  const ExamPreparation({super.key});

  @override
  State<ExamPreparation> createState() => _ExamPreparationState();
}

class _ExamPreparationState extends State<ExamPreparation> {
  List<Menu> examPreparationMenu = [
    Menu(
        color: 0xFFF2C6DF, // Corrected color code
        imagePath: 'assets/svg/examprep_logo.svg',
        navigation: null,
        title: 'Maharashtra HSC Paper '),
    Menu(
        color: 0xFFC5DEF2,
        imagePath: 'assets/svg/examprep_logo.svg',
        navigation: null,
        title: 'Maths model paper'),
    Menu(
        color: 0xFFC9E4DF, // Corrected color code
        imagePath: 'assets/svg/examprep_logo.svg',
        navigation: null,
        title: 'Physics model paper'),
    Menu(
        color: 0xFFF8D9C4,
        imagePath: 'assets/svg/examprep_logo.svg',
        navigation: null,
        title: 'Chemistry model paper'),
    Menu(
        color: 0xFFDBCDF0,
        imagePath: 'assets/svg/examprep_logo.svg',
        navigation: null,
        title: 'Biology model paper'),
    Menu(
        color: 0xFFFAEDCB,
        imagePath: 'assets/svg/abouticon.svg',
        navigation: null,
        title: 'About JEE Main 2018'),
    Menu(
        color: 0xFFFAEDCB,
        imagePath: 'assets/svg/abouticon.svg',
        navigation: null,
        title: 'About NEET 2018'),
  ];
  final GlobalKey<ScaffoldState> _examscaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
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
          title: const Text(
            "Exam Preparation",
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
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: examPreparationMenu.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
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
      drawer: DrawerWidget(context),
    );
  }
}
