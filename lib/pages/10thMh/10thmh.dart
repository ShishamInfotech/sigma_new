import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sigma_new/models/menu_models.dart';
import 'package:sigma_new/pages/board_mock_exam/subject_wise.dart';
import 'package:sigma_new/pages/board_syallabus/subject_wise_syllabus.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/pages/home/jee/jee_neet_home.dart';
import 'package:sigma_new/ui_helper/constant.dart';

import '../../utility/sponsors_loader.dart';

class StandardMenu extends StatefulWidget {
  var standard;
  StandardMenu({this.standard, super.key});

  @override
  State<StandardMenu> createState() => _StandardMenuState();
}

class _StandardMenuState extends State<StandardMenu> {


  final GlobalKey<ScaffoldState> _examscaffoldKey = GlobalKey<ScaffoldState>();

  final repo = SponsorsRepository();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    List<Menu> examPreparationMenu = [
      Menu(
          color: 0xFFFAEDCB, // Corrected color code
          imagePath: 'assets/svg/board_syllabus.svg',
          navigation:() {

          },
          title: 'Syllabus'),
      if(!widget.standard.toString().contains("IIT"))Menu(
          color: 0xFFC9E4DF,
          imagePath: 'assets/svg/exam_preparation_logo.svg',
          navigation: (){

          },
          title: 'Board Mock Exams'),
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
      body: ListView(
        padding: const EdgeInsets.only(top: 30.0, bottom: 24.0),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              // remove the fixed height so GridView can size itself in the ListView
              width: MediaQuery.of(context).size.width * 0.85,
              child: GridView.builder(
                shrinkWrap: true, // allow GridView to size itself inside ListView
                physics: const NeverScrollableScrollPhysics(), // avoid nested scroll conflicts
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
                            if(widget.standard.toString().contains("IIT")){
                              Get.to(JeeNeetHome());
                            } else {
                              examPreparationMenu[index].navigation!();
                              Get.to(BoardWiseSyllabus(path: widget.standard,));
                            }
                          } else {
                            print('No navigation route defined for this menu item');
                          }
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
                              examPreparationMenu[index].imagePath,
                              height: MediaQuery.of(context).size.height * 0.07,
                              width: MediaQuery.of(context).size.width * 0.07,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
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

          const SizedBox(height: 10),

          // ⭐ Sponsors placed below the syllabus & board exam sections
          SizedBox(
            height: 472, // fixed panel height so it renders predictably
            child: SponsorsLoader(fetcher: () => repo.fetchSponsorsFromSdCard()),
          ),

          // optional extra spacing
          const SizedBox(height: 24),
        ],
      ),

      drawer: DrawerWidget(),
    );
  }
}
