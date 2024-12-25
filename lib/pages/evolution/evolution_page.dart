import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sigma_new/models/evaluation_models.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/ui_helper/constant.dart';

import '../../ui_helper/constant_widgets.dart';

class EvolutionPage extends StatefulWidget {
  const EvolutionPage({super.key});

  @override
  State<EvolutionPage> createState() => _EvolutionPageState();
}

class _EvolutionPageState extends State<EvolutionPage> {
  List<EvaluationModels> evaluationmodel = [
    EvaluationModels(
        subject: 'Chemistry', level: 'Simple', score: 10, color: 0xFFC9E4DF),
    EvaluationModels(
        subject: 'Physics', level: 'Medium', score: 52, color: 0xFFC5DEF2),
    EvaluationModels(
        subject: 'Science', level: 'Hard', score: 43, color: 0xFFDBCDF0)
  ];
  final GlobalKey<ScaffoldState> _evolutionscaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: Colors.white,
      // backgroundColor: backgroundColor,
      key: _evolutionscaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          (isPortrait) ? height * 0.27 : height * 0.5,
        ),
        child: Stack(
          children: [
            AppBar(
                // backgroundColor: backgroundColor,
                leading: InkWell(
                  onTap: () {
                    _evolutionscaffoldKey.currentState?.openDrawer();
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
                title: Text(
                  "Evaluation",
                  style: black20w400MediumTextStyle,
                )),
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
                            SvgPicture.asset(
                                "assets/svg/completed_evaluation.svg"),
                            Text(
                              "Completed",
                              style: black10MediumTextStyle,
                            ),
                            Text(
                              "10",
                              style: primaryColor18BoldTextStyle,
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: height * 0.08,
                        child: VerticalDivider(
                          color: primaryColor,
                          thickness: 1,
                          width: 15,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                                "assets/svg/totalscore_evaluation.svg"),
                            Text(
                              "Total Score",
                              style: black10MediumTextStyle,
                            ),
                            Text(
                              "10",
                              style: primaryColor18BoldTextStyle,
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: height * 0.08,
                        child: VerticalDivider(
                          color: primaryColor,
                          thickness: 1,
                          width: 15,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                                "assets/svg/averge_evaluation.svg"),
                            Text(
                              "Average",
                              style: black10MediumTextStyle,
                            ),
                            Text(
                              "10",
                              style: primaryColor18BoldTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: height * 0.08,
                        child: VerticalDivider(
                          color: primaryColor,
                          thickness: 1,
                          width: 15,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                  "assets/svg/subjectwisetest_evaluation.svg"),
                              Text(
                                "Current Test Level",
                                style: black10MediumTextStyle,
                              ),
                              Text(
                                "Simple",
                                style: primaryColor16MediumTextStyle,
                              ),
                            ],
                          ),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mock Exam",
              style: black12MediumTextStyle,
            ),
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
      drawer: DrawerWidget(context),
    );
  }
}
