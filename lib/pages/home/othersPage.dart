import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sigma_new/models/menu_models.dart';
import 'package:sigma_new/pages/exam_preparation/exam_preparation.dart';
import 'package:sigma_new/pages/home/quick_guide/quick_guide.dart';
import 'package:sigma_new/ui_helper/constant.dart';

import '../pdf/PdfFolderListPage.dart';

class OtherPage extends StatefulWidget {
  const OtherPage({super.key});

  @override
  State<OtherPage> createState() => _Appbar2State();
}

class _Appbar2State extends State<OtherPage> {
  @override
  Widget build(BuildContext context) {
    List<Menu> studyMenu = [
      Menu(
          color: 0xFFF2C6DF,
          imagePath: 'assets/svg/calculator.svg',
          navigation: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("UI not defined in WireFrame"),
                duration: Duration(seconds: 2),
              ),
            );
          },
          title: 'Calculator'),
      Menu(
          color: 0xFFC5DEF2,
          imagePath: 'assets/svg/motivational_stories.svg',
          navigation: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                const PdfFolderListPage(title: 'Motivation Stories', folderName: 'motivationstories',)));
          },
          title: 'Motivation Stories'),
      Menu(
          color: 0xFFC9E4DF,
          imagePath: 'assets/svg/logbook.svg',
          navigation: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                const PdfFolderListPage(title: 'Log Book', folderName: 'logbook',)));
          },
          title: 'Log Book'),
      Menu(
          color: 0xFFF8D9C4,
          imagePath: 'assets/svg/quick_guide.svg',
          navigation: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                const PdfFolderListPage(title: 'Quick Guide', folderName: 'quickguide',)));
          },
          title: 'Quick Guide'),
      Menu(
          color: 0xFFDBCDF0,
          imagePath: 'assets/svg/course_outline.svg',
          navigation: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                  const PdfFolderListPage(title: 'Course Outline', folderName: 'courseoutline',)));
          },
          title: 'Course Outline'),
      Menu(
          color: 0xFFFAEDCB,
          imagePath: 'assets/svg/exam_prep.svg',
          navigation: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                const PdfFolderListPage(title: 'Exam Preparation', folderName: 'examprep',)));
          },
          title: 'Exam Preparation'),
    ];
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width * 0.9,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  const SizedBox(
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
