import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/ui_helper/constant.dart';

class EvolutionPage extends StatefulWidget {
  const EvolutionPage({super.key});

  @override
  State<EvolutionPage> createState() => _EvolutionPageState();
}

class _EvolutionPageState extends State<EvolutionPage> {
  final GlobalKey<ScaffoldState> _evolutionscaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      key: _evolutionscaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          (isPortrait) ? height * 0.27 : height * 0.5,
        ),
        child: Stack(
          children: [
            AppBar(
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
                            SvgPicture.asset(
                                "assets/svg/totalscore_evaluation.svg"),
                            Text(
                              "Total Score",
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
                            SvgPicture.asset(
                                "assets/svg/averge_evaluation.svg"),
                            Text(
                              "Average",
                              style: black10MediumTextStyle,
                            ),
                            Text(
                              "10",
                              style: primaryColor24w600TextStyle,
                            ),
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
                            SvgPicture.asset(
                                "assets/svg/subjectwisetext_evaluation_evaluation.svg"),
                            Text(
                              "Current Test Level",
                              style: black10MediumTextStyle,
                            ),
                            Text(
                              "10",
                              style: primaryColor24w600TextStyle,
                            ),
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
      body: Column(
        children: [],
      ),
      drawer: DrawerWidget(context),
    );
  }
}
