import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sigma_new/models/menu_models.dart';
import 'package:sigma_new/pages/exam_preparation/exam_preparation.dart';
import 'package:sigma_new/pages/home/quick_guide/quick_guide.dart';
import 'package:sigma_new/ui_helper/constant.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _Appbar2State();
}

class _Appbar2State extends State<StudyPage> {
  @override
  Widget build(BuildContext context) {
    List<Menu> studyMenu = [
      Menu(
          color: 0xFFF2C6DF, // Corrected color code
          imagePath: 'assets/svg/calculator.svg',
          navigation: null,
          // () {
          //   Navigator.push(
          //       context, MaterialPageRoute(builder: (context) => QuickGuide()));
          // },
          title: 'Calculator'),
      Menu(
          color: 0xFFC5DEF2,
          imagePath: 'assets/svg/motivational_stories.svg',
          navigation: null,
          title: 'Motivation Stories'),
      Menu(
          color: 0xFFC9E4DF, // Corrected color code
          imagePath: 'assets/svg/logbook.svg',
          navigation: null,
          title: 'Log Book'),
      Menu(
          color: 0xFFF8D9C4,
          imagePath: 'assets/svg/quick_guide.svg',
          navigation: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => QuickGuide()));
          },
          title: 'Quick Guide'),
      Menu(
          color: 0xFFDBCDF0,
          imagePath: 'assets/svg/course_outline.svg',
          navigation: null,
          title: 'Course Outline'),
      Menu(
          color: 0xFFFAEDCB,
          imagePath: 'assets/svg/exam_prep.svg',
          navigation: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ExamPreparation()));
          },
          title: 'Exam Preparation'),
    ];
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width * 0.9,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: studyMenu.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      if (studyMenu[index].navigation != null) {
                        studyMenu[index].navigation!();
                      } else {
                        print('No navigation route defined for this menu item');
                      }
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.13,
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(studyMenu[index].color),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SvgPicture.asset(
                          studyMenu[index].imagePath, // Correct interpolation
                          height: 30,
                          width: 30,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    studyMenu[index].title,
                    style: black14w400MediumTextStyle,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
