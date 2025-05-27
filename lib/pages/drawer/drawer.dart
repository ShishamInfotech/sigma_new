import 'package:flutter/material.dart';
import 'package:sigma_new/pages/evolution/evolution_page.dart';
import 'package:sigma_new/pages/exam_preparation/exam_preparation.dart';
import 'package:sigma_new/pages/home/home.dart';
import 'package:sigma_new/pages/usage_report/usage_report_page.dart';
import 'package:sigma_new/supports/fetchDeviceDetails.dart';
import 'package:sigma_new/ui_helper/constant.dart';

import '../library/LibraryHome.dart';

@override
Widget DrawerWidget(BuildContext context) {
  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: primaryColor,
          ),
          child: Text(
            'Device Details\n',
            style: white18MediumTextStyle,
          ),
        ),
        ListTile(
          title: const Text('Home'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Library'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => LibraryHome()));
          },
        ),
        ListTile(
          title: const Text('Real Time Monitoring Report'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UsageReportPage(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Exam Preperation'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExamPreparation(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Exam Evaluation Bucket'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EvaluationPage(),
              ),
            );
          },
        ),
        ListTile(
          title: Text("Device Id: ${deviceId()}"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EvaluationPage(),
              ),
            );
          },
        ),
      ],
    ),
  );
}
