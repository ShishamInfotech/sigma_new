import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/models/mock_exam_table.dart';
import 'package:sigma_new/models/targetDatesModel.dart';
import 'package:sigma_new/pages/drawer/drawer.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/ui_helper/constant_widgets.dart';
// Import your AppUsageTracker

class UsageReportPage extends StatefulWidget {
  const UsageReportPage({super.key});

  @override
  State<UsageReportPage> createState() => _UsageReportPageState();
}

class _UsageReportPageState extends State<UsageReportPage> {
  Duration today = Duration.zero;
  Duration yesterday = Duration.zero;
  Duration total = Duration.zero;

  @override
  void initState() {
    super.initState();
   // AppUsageTracker.startTracking(); // Start tracking app usage
   // AppUsageTracker.startAutoSave(); // Optionally auto-save periodically
    loadUsageData();
  }

  Future<void> loadUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    String todayKey = "${now.year}-${now.month}-${now.day}";
    String yesterdayKey = "${now.year}-${now.month}-${now.day - 1}";

    // Get the value for today and yesterday, ensuring it's converted to an int
    int todayDuration = prefs.get(todayKey) is int
        ? prefs.getInt(todayKey) ?? 0
        : int.tryParse(prefs.getString(todayKey) ?? '') ?? 0;

    int yesterdayDuration = prefs.get(yesterdayKey) is int
        ? prefs.getInt(yesterdayKey) ?? 0
        : int.tryParse(prefs.getString(yesterdayKey) ?? '') ?? 0;

    Duration todayDurationObj = Duration(seconds: todayDuration);
    Duration yesterdayDurationObj = Duration(seconds: yesterdayDuration);
    Duration totalDuration = Duration.zero;

    for (var key in prefs.getKeys()) {
      final value = prefs.get(key);
      if (value is int) {
        totalDuration += Duration(seconds: value);
      } else if (value is String) {
        totalDuration += Duration(seconds: int.tryParse(value) ?? 0);
      }
    }

    setState(() {
      today = todayDurationObj;
      yesterday = yesterdayDurationObj;
      total = totalDuration;
    });
  }

  String formatTime(Duration d) {
    return "${d.inHours}h ${d.inMinutes.remainder(60)}m";
  }

  @override
  void dispose() {
    AppUsageTracker.stopTracking(); // Stop tracking when leaving the page
    super.dispose();
  }

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

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          (isPortrait) ? height * 0.08 : height * 0.5,
        ),
        child: Stack(
          children: [
            AppBar(
              leading: InkWell(
                onTap: () {
                  scaffoldKey.currentState?.openDrawer();
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
              title: Row(
                children: [
                  Image.asset("assets/svg/profile.png"),
                  SizedBox(width: width * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Welcome back 👋", style: black12MediumTextStyle),
                      Text("Let's Start Learning", style: primaryColor12MediumTextStyle),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: whiteColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Real time study time (In hours)", style: black12MediumTextStyle),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: infoCard(
                        title: "Yesterday",
                        number: formatTime(yesterday),
                        color: const Color(0xFFFAEDCB),
                        context: context,
                      ),
                    ),
                    Expanded(
                      child: infoCard(
                        title: "Today",
                        number: formatTime(today),
                        color: const Color(0xFFC9E4DF),
                        context: context,
                      ),
                    ),
                    Expanded(
                      child: infoCard(
                        title: "To Date",
                        number: formatTime(total),
                        color: const Color(0xFFC5DEF2),
                        context: context,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                const Text("Real time analytical data of study (In hours)", style: black12MediumTextStyle),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: infoCard(
                        title: "Average study \ntime per day",
                        number: "0",
                        color: const Color(0xFFDBCDF0),
                        context: context,
                      ),
                    ),
                    Expanded(
                      child: infoCard(
                        title: "Lowest study time",
                        number: "0",
                        color: const Color(0xFFF8D9C4),
                        context: context,
                      ),
                    ),
                    Expanded(
                      child: infoCard(
                        title: "Highest study time",
                        number: "0",
                        color: const Color(0xFFF2C6DF),
                        context: context,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                const Text("Target dates to complete subjects", style: black12MediumTextStyle),
                targetDatesTable(context: context, data: targetDatesList),
                const Text("To date Level wise performance in Mock Examinations", style: black12MediumTextStyle),
                mockExamTable(examData: tableData, context: context),
              ],
            ),
          ),
        ),
      ),
      drawer: DrawerWidget(context),
    );
  }
}





class AppUsageTracker {
  static late Timer _timer;
  static int _secondsSpent = 0;

  // Start the timer to track usage every second
  static void startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsSpent++;
    });
  }

  // Save the time spent today to SharedPreferences
  static Future<void> saveUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = "${now.year}-${now.month}-${now.day}"; // unique key for today

    int currentStored = 0;
    var value = prefs.get(key);
    if (value is int) {
      currentStored = value;
    } else if (value is String) {
      currentStored = int.tryParse(value) ?? 0;
    }

    // Save new time
    await prefs.setInt(key, currentStored + _secondsSpent);
    _secondsSpent = 0; // reset counter after saving
  }

  // Stop tracking and save the data
  static void stopTracking() {
    _timer.cancel();
    saveUsage(); // save time on stop
  }

  // Optionally, save periodically to avoid data loss on app crashes
  static void startAutoSave() {
    Timer.periodic(const Duration(minutes: 1), (_) {
      saveUsage();
    });
  }
}
