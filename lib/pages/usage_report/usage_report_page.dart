import 'package:flutter/material.dart';
import 'package:sigma_new/models/mock_exam_table.dart';
import 'package:sigma_new/models/targetDatesModel.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/ui_helper/constant_widgets.dart';

class UsageReportPage extends StatelessWidget {
  const UsageReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<MockExamTable> tableData = [
      MockExamTable(boardExam: "Maths", examsAttempted: 11, level: "Simple"),
      MockExamTable(boardExam: "Physics", examsAttempted: 7, level: "Medium"),
      MockExamTable(boardExam: "Chemistry", examsAttempted: 1, level: "Hard"),
      MockExamTable(boardExam: "Biology", examsAttempted: 8, level: "Complex"),
    ];
    List<TargetDatesModel> targetDatesList = [
      TargetDatesModel(
          daysRemaining: 2,
          presentStatus: 30,
          subjectName: "Maths",
          targetDates: "21/12/2024"),
      TargetDatesModel(
          daysRemaining: 14,
          presentStatus: 64,
          subjectName: "Chemistry",
          targetDates: "21/12/2024"),
    ];

    final GlobalKey<ScaffoldState> _scaffoldKey =
        GlobalKey<ScaffoldState>(); // Define a GlobalKey

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          (isPortrait) ? height * 0.08 : height * 0.5,
        ),
        child: Stack(
          children: [
            AppBar(
              leading: InkWell(
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: Icon(Icons.menu),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
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
              title: Row(
                children: [
                  Image.asset("assets/svg/profile.png"),
                  SizedBox(width: width * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back 👋",
                        style: black12MediumTextStyle,
                      ),
                      Text(
                        "Let's Start Learning",
                        style: primaryColor12MediumTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Positioned(
            //   top: (isPortrait) ? height * 0.15 : height * 0.25,
            //   left: 0,
            //   right: 0,
            //   child: Card(
            //     elevation: 6,
            //     shadowColor: primaryColor,
            //     margin: EdgeInsets.symmetric(horizontal: 16),
            //     child: Padding(
            //       padding: const EdgeInsets.only(top: 15.0, bottom: 5),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //         children: [
            //           Padding(
            //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 SvgPicture.asset("assets/svg/watch.svg"),
            //                 Text(
            //                   "Total Time spent",
            //                   style: black10MediumTextStyle,
            //                 ),
            //                 Text(
            //                   "10",
            //                   style: primaryColor24w600TextStyle,
            //                 )
            //               ],
            //             ),
            //           ),
            //           Container(
            //             height: height * 0.08,
            //             child: VerticalDivider(
            //               color: primaryColor,
            //               thickness: 1,
            //               width: 20,
            //             ),
            //           ),
            //           Padding(
            //             padding: EdgeInsets.symmetric(horizontal: 10.0),
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 SvgPicture.asset("assets/svg/clock.svg"),
            //                 Text(
            //                   "Total time daily",
            //                   style: black10MediumTextStyle,
            //                 ),
            //                 Text(
            //                   "10",
            //                   style: primaryColor24w600TextStyle,
            //                 )
            //               ],
            //             ),
            //           ),
            //           Container(
            //             height: height * 0.08,
            //             child: VerticalDivider(
            //               color: primaryColor,
            //               thickness: 1,
            //               width: 20,
            //             ),
            //           ),
            //           Padding(
            //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 SvgPicture.asset("assets/svg/app_visits.svg"),
            //                 Text(
            //                   "App visit",
            //                   style: black10MediumTextStyle,
            //                 ),
            //                 Text(
            //                   "10",
            //                   style: primaryColor24w600TextStyle,
            //                 )
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: whiteColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Real time study time (In hours)",
                    style: black12MediumTextStyle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: infoCard(
                          title: "Yesterday",
                          number: "1",
                          color: Color(0xFFFAEDCB),
                          context: context,
                        ),
                      ),
                      Expanded(
                        child: infoCard(
                            title: "Today",
                            number: "3",
                            color: Color(0xFFC9E4DF),
                            context: context),
                      ),
                      Expanded(
                        child: infoCard(
                          title: "To Date",
                          number: "1",
                          color: Color(0xFFC5DEF2),
                          context: context,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Text(
                    "Real time analytical data of study (In hours)",
                    style: black12MediumTextStyle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: infoCard(
                          title: "Average study \ntime per day",
                          number: "0",
                          color: Color(0xFFDBCDF0),
                          context: context,
                        ),
                      ),
                      Expanded(
                          child: infoCard(
                              title: "Lowest study time",
                              number: "0",
                              color: Color(0xFFF8D9C4),
                              context: context)),
                      Expanded(
                        child: infoCard(
                          title: "Highest study time",
                          number: "0",
                          color: Color(0xFFF2C6DF),
                          context: context,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  const Text(
                    "Target dates to complete subjects",
                    style: black12MediumTextStyle,
                  ),
                  targetDatesTable(context: context, data: targetDatesList),
                  Text(
                    "To date Level wise performance in Mock Examinations",
                    style: black12MediumTextStyle,
                  ),
                  mockExamTable(examData: tableData, context: context),
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: DrawerWidget(context),
    );
  }
}
