import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/ui_helper/constant_widgets.dart';

import '../../models/evaluation_models.dart';

class UsageReportPage extends StatelessWidget {
  const UsageReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<EvaluationModels> evaluationmodel = [
      EvaluationModels(
          subject: 'Chemistry', level: 'Simple', score: 10, color: 0xFFC9E4DF),
      EvaluationModels(
          subject: 'Physics', level: 'Medium', score: 52, color: 0xFFC5DEF2),
      EvaluationModels(
          subject: 'Science', level: 'Hard', score: 43, color: 0xFFDBCDF0)
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
          (isPortrait) ? height * 0.27 : height * 0.5,
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
            Positioned(
              top: (isPortrait) ? height * 0.15 : height * 0.25,
              left: 0,
              right: 0,
              child: Card(
                elevation: 6,
                shadowColor: primaryColor,
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset("assets/svg/watch.svg"),
                            Text(
                              "Total Time spent",
                              style: black10MediumTextStyle,
                            ),
                            Text(
                              "10",
                              style: primaryColor24w600TextStyle,
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: height * 0.08,
                        child: VerticalDivider(
                          color: primaryColor,
                          thickness: 1,
                          width: 20,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset("assets/svg/clock.svg"),
                            Text(
                              "Total time daily",
                              style: black10MediumTextStyle,
                            ),
                            Text(
                              "10",
                              style: primaryColor24w600TextStyle,
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: height * 0.08,
                        child: VerticalDivider(
                          color: primaryColor,
                          thickness: 1,
                          width: 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset("assets/svg/app_visits.svg"),
                            Text(
                              "App visit",
                              style: black10MediumTextStyle,
                            ),
                            Text(
                              "10",
                              style: primaryColor24w600TextStyle,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: whiteColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Study Details",
                  style: black12MediumTextStyle,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: infoCard(
                        title: "Videos",
                        number: "0",
                        color: Color(0xFFFAEDCB),
                        context: context,
                      ),
                    ),
                    Expanded(
                      child: infoCard(
                          title: "Answers visited",
                          number: "0",
                          color: Color(0xFFC9E4DF),
                          context: context),
                    ),
                    Expanded(
                      child: infoCard(
                        title: "MCQs practiced",
                        number: "0",
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
                  "Test Performance",
                  style: black12MediumTextStyle,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: infoCard(
                        title: "Test given",
                        number: "0",
                        color: Color(0xFFDBCDF0),
                        context: context,
                      ),
                    ),
                    Expanded(
                        child: infoCard(
                            title: "Average score",
                            number: "0",
                            color: Color(0xFFF8D9C4),
                            context: context)),
                    Expanded(
                      child: infoCard(
                        title: "Top score",
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
                Text(
                  "Mock exam",
                  style: black12MediumTextStyle,
                ),
                // ListView.builder(
                //   physics: NeverScrollableScrollPhysics(),
                //   shrinkWrap: true,
                //   itemBuilder: (context, index) {
                //     List colorList = [
                //       Color(0xFFC9E4DF),
                //       Color(0xFFC5DEF2),
                //       Color(0xFFDBCDF0)
                //     ];
                //     return mockExamCard(
                //         subjectName: "Chemistry",
                //         level: "Easy",
                //         topScore: "43",
                //         color: colorList[index % 3],
                //         context: context);
                //   },
                //   itemCount: 3,
                // ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: evaluationCard(
                            subject: evaluationmodel[index].subject,
                            level: evaluationmodel[index].level,
                            score: evaluationmodel[index].score.toString(),
                            color: evaluationmodel[index].color,
                            context: context));
                  },
                  itemCount: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: DrawerWidget(context),
    );
  }
}
