import 'package:flutter/material.dart';
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
                builder: (context) => HomePage(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Books'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
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
                builder: (context) => UsageReportPage(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Exam Prep'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Evaluation'),
          onTap: () {},
        ),
      ],
    ),
  );
}
