import 'package:flutter/material.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/questions/easy_questions.dart';
import 'package:sigma_new/ui_helper/constant.dart';

class TableQuiz extends StatefulWidget {
  const TableQuiz({super.key});

  @override
  State<TableQuiz> createState() => _TableQuizState();
}

class _TableQuizState extends State<TableQuiz> {
  final GlobalKey<ScaffoldState> _tablequizscaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: DrawerWidget(context),
        key: _tablequizscaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            (isPortrait) ? height * 0.08 : height * 0.5,
          ),
          child: Stack(
            children: [
              AppBar(
                  // backgroundColor: backgroundColor,
                  leading: InkWell(
                    onTap: () {
                      _tablequizscaffoldKey.currentState?.openDrawer();
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
                  title: const Text(
                    "Mathematical Logic",
                    style: black20w400MediumTextStyle,
                  )),
            ],
          ),
        ),
        body: Column(
          children: [
            height10Space,
            Padding(
              padding: const EdgeInsets.only(right: 65.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
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
                        "Easy",
                      ),
                    ),
                    Tab(
                      child: Text("Medium"),
                    ),
                    Tab(
                      child: Text("Complex"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Expanded(
              child: TabBarView(children: [
                EasyQuestions(),
              //  MediumQuestions(),
              //  ComplexQuestions()
              ]),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
