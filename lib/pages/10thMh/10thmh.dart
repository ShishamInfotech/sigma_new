import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/models/menu_models.dart';
import 'package:sigma_new/pages/board_mock_exam/subject_wise.dart';
import 'package:sigma_new/pages/board_syallabus/subject_wise_syllabus.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/questions/table_quiz.dart';
import 'package:sigma_new/ui_helper/constant.dart';

class StandardMenu extends StatefulWidget {
  var standard;
  StandardMenu({this.standard, super.key});

  @override
  State<StandardMenu> createState() => _StandardMenuState();
}

class _StandardMenuState extends State<StandardMenu> {


  final GlobalKey<ScaffoldState> _examscaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    List<Menu> examPreparationMenu = [
      if(widget.standard!="JEE")Menu(
          color: 0xFFFAEDCB, // Corrected color code
          imagePath: 'assets/svg/board_syllabus.svg',
          navigation:() {

          },
          title: 'Board Syllabus'),
      Menu(
          color: 0xFFC9E4DF,
          imagePath: 'assets/svg/exam_preparation_logo.svg',
          navigation: (){

          },
          title: 'Board Mock Exam'),
    ];
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
          title: Text(
            widget.standard,
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
                            if (examPreparationMenu[index].navigation != null && index==1) {
                              examPreparationMenu[index].navigation!();
                                  Get.to(SubjectWise(path: widget.standard,));
                            } else if(index==0) {
                              examPreparationMenu[index].navigation!();
                              Get.to(BoardWiseSyllabus(path: widget.standard,));

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
      drawer: DrawerWidget(context),
    );
  }
}
