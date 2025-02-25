import 'package:flutter/material.dart';
import 'package:sigma_new/pages/evolution/evolution_page.dart';
import 'package:sigma_new/pages/exam_preparation/exam_preparation.dart';
import 'package:sigma_new/pages/home/home.dart';
import 'package:sigma_new/pages/usage_report/usage_report_page.dart';
import 'package:sigma_new/ui_helper/constant.dart';

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
            'Drawer Header',
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
          title: const Text('Books'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("UI not defined in WireFrame"),
                duration: Duration(seconds: 3),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Report'),
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
          title: const Text('Exam Prep'),
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
          title: const Text('Evaluation'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EvolutionPage(),
              ),
            );
          },
        ),
      ],
    ),
  );
}
