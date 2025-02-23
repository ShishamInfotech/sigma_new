
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/ui_helper/constant_widgets.dart';

class UsageReportPage extends StatelessWidget {
  const UsageReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          (isPortrait) ? height * 0.27 : height * 0.5,
        ), // Adjust the height to include the Card
        child: Stack(
          children: [
            AppBar(
              leading: const Icon(Icons.menu),
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
              title: Row(
                children: [
                  Image.asset("assets/svg/profile.png"),
                  SizedBox(width: width * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
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
                margin: const EdgeInsets.symmetric(
                    horizontal: 16), // Add horizontal padding
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
                            const Text(
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
                      SizedBox(
                        height: height * 0.08,
                        child: const VerticalDivider(
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
                            SvgPicture.asset("assets/svg/clock.svg"),
                            const Text(
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
                      SizedBox(
                        height: height * 0.08,
                        child: const VerticalDivider(
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
                            const Text(
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
                const Text(
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
                        color: const Color(0xFFFAEDCB),
                        context: context,
                      ),
                    ),
                    Expanded(
                      child: infoCard(
                          title: "Answers visited",
                          number: "0",
                          color: const Color(0xFFC9E4DF),
                          context: context),
                    ),
                    Expanded(
                      child: infoCard(
                        title: "MCQs practiced",
                        number: "0",
                        color: const Color(0xFFC5DEF2),
                        context: context,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                const Text(
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
                        color: const Color(0xFFDBCDF0),
                        context: context,
                      ),
                    ),
                    Expanded(
                        child: infoCard(
                            title: "Average score",
                            number: "0",
                            color: const Color(0xFFF8D9C4),
                            context: context)),
                    Expanded(
                      child: infoCard(
                        title: "Top score",
                        number: "0",
                        color: const Color(0xFFF2C6DF),
                        context: context,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                const Text(
                  "Mock exam",
                  style: black12MediumTextStyle,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    // There will be a dynamic List here when we will get we will convert it
                    List colorList = [
                      const Color(0xFFC9E4DF),
                      const Color(0xFFC5DEF2),
                      const Color(0xFFDBCDF0)
                    ];
                    // API Value will be recieved here
                    return mockExamCard(
                        subjectName: "Chemistry",
                        level: "Easy",
                        topScore: "43",
                        color: colorList[index % 3],
                        context: context);
                  },
                  itemCount: 3,
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                SizedBox(
                  height: height * 0.01,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
