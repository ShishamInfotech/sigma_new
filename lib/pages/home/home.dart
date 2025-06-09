import 'package:flutter/material.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/pages/home/othersPage.dart';
import 'package:sigma_new/pages/home/studyPage.dart';
import 'package:sigma_new/ui_helper/constant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _homeScaffoldKey =
      GlobalKey<ScaffoldState>();



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _homeScaffoldKey,
        appBar: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 70),
            child: AppBar(
                leading: InkWell(
                    onTap: () {
                      _homeScaffoldKey.currentState?.openDrawer();
                    },
                    child: const Icon(Icons.view_headline_outlined)),
                title: Row(
                  children: [
                    Image.asset(
                      'assets/svg/profile.png', // Correct interpolation
                      height: 40,
                      width: 40,
                      fit: BoxFit.contain,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome back👋",
                            style: black16w400MediumTextStyle,
                          ),
                          Text(
                            "Let’s start learning",
                            style: primaryColor16MediumTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ))),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 160.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white),
                  child: TabBar(
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.rectangle,
                    ),
                    padding: const EdgeInsets.all(5),
                    labelPadding: const EdgeInsets.all(5),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: primaryColor,
                    unselectedLabelColor: blackColor,
                    splashBorderRadius: BorderRadius.circular(5),
                    indicatorColor: backgroundColor,
                    tabs: const [
                      Tab(
                        child: Text(
                          "Study",
                        ),
                      ),
                      Tab(
                        child: Text("Other"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: const TabBarView(children: [
                  StudyPage(),
                  OtherPage(),
                ]),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
        drawer: DrawerWidget(),
      ),
    );
  }
}
