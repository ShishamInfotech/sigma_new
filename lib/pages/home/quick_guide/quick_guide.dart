import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../models/menu_models.dart';
import '../../../ui_helper/constant.dart';

class QuickGuide extends StatefulWidget {
  const QuickGuide({super.key});
  // final GlobalKey<ScaffoldState> _quickguidescaffoldkey = GlobalKey<ScaffoldState>();

  @override
  State<QuickGuide> createState() => _QuickGuideState();
}

class _QuickGuideState extends State<QuickGuide> {
  List<Menu> examPreparationMenu = [
    Menu(
        color: 0xFFF2C6DF, // Corrected color code
        imagePath: 'assets/svg/quickguideimg.svg',
        navigation: null,
        title: 'Maths'),
    Menu(
        color: 0xFFC5DEF2,
        imagePath: 'assets/svg/quickguideimg.svg',
        navigation: null,
        title: 'Physics'),
    Menu(
        color: 0xFFC9E4DF, // Corrected color code
        imagePath: 'assets/svg/quickguideimg.svg',
        navigation: null,
        title: 'Chemistry'),
    Menu(
        color: 0xFFF8D9C4,
        imagePath: 'assets/svg/quickguideimg.svg',
        navigation: null,
        title: 'Biology'),
  ];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          // backgroundColor: backgroundColor,
          leading: InkWell(
            onTap: () {
              print("Opening Drawer");
              // _quickquidescaffoldKey.currentState?.openDrawer();
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
            "Quick Guide",
            style: black20w400MediumTextStyle,
          )),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.85,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 0,
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
                            height: height * 0.13,
                            width: width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(examPreparationMenu[index].color),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SvgPicture.asset(
                                examPreparationMenu[index]
                                    .imagePath, // Correct interpolation
                                height: height * 0.08,
                                width: width * 0.08,
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
    );
  }
}
