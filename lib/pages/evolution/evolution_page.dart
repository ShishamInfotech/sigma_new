import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/ui_helper/constant.dart';

import 'mock_exam_details.dart'; // You'll create this next

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({super.key});

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  List<Map<String, dynamic>> submissions = [];

  @override
  void initState() {
    super.initState();
    loadSubmissions();
  }

  Future<void> loadSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('mock_submissions');
    if (stored != null) {
      try {
        final parsed = jsonDecode(stored) as List;
        submissions = parsed.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (_) {
        submissions = [];
      }
    }
    setState(() {});
  }  

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
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                            const Text(
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
                      SizedBox(
                        height: height * 0.08,
                        child: const VerticalDivider(
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
                                "assets/svg/totalscore_evaluation.svg"),
                            const Text(
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
                      SizedBox(
                        height: height * 0.08,
                        child: const VerticalDivider(
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
                            const Text(
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
                      SizedBox(
                        height: height * 0.08,
                        child: const VerticalDivider(
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
                              const Text(
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
        child: submissions.isEmpty
            ? const Center(child: Text("No submitted mocks found."))
            : ListView.builder(
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            final sub = submissions[index];
            final title = sub['title'] ?? 'Untitled';
            final timestamp = sub['timestamp'] ?? '';
            final dateTime = DateTime.tryParse(timestamp);

            return ListTile(
              title: Text(title),
              subtitle: Text(dateTime != null
                  ? '${dateTime.toLocal()}'
                  : 'Unknown time'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MockExamDetailPage(
                      title: title,
                      timestamp: timestamp,
                      questions: List<Map<String, dynamic>>.from(sub['questions']),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      drawer: DrawerWidget(context),
    );
  }
}
