import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sigma_new/config/config.dart';
import 'package:sigma_new/config/config_loader.dart';
import 'package:sigma_new/pages/evolution/evolution_page.dart';
import 'package:sigma_new/pages/exam_preparation/exam_preparation.dart';
import 'package:sigma_new/pages/home/home.dart';
import 'package:sigma_new/pages/usage_report/usage_report_page.dart';
import 'package:sigma_new/side_navigation/about_us.dart';
import 'package:sigma_new/side_navigation/sigma_team.dart';
import 'package:sigma_new/supports/fetchDeviceDetails.dart';
import 'package:sigma_new/ui_helper/constant.dart';

import '../../side_navigation/info_folder_page.dart';
import '../library/LibraryHome.dart';
import '../report/real_time_usage_reports.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late Future<Config?> _configFuture;

  @override
  void initState() {
    super.initState();
    _configFuture = ConfigLoader.getGlobalConfig(); // Only called once
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Config?>(
      future: _configFuture,
      builder: (context, snapshot) {
        String startDate = 'Loading...';
        String endDate = 'Loading...';
        String company = 'Loading...';

        if (snapshot.hasData) {
          startDate = snapshot.data!.startDate ?? 'Not available';
          endDate = snapshot.data!.expiryDate ?? 'Not available';
          company = snapshot.data!.copyright ?? "Not Available";
        } else if (snapshot.hasError) {
          startDate = 'Error loading';
          endDate = 'Error loading';
        }

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 250,
                color: primaryColor,
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  margin: EdgeInsets.only(top: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Device Details', style: white16w400MediumTextStyle),
                      const SizedBox(height: 10),
                      Text('Start Date: $startDate', style: white16w400MediumTextStyle),
                      const SizedBox(height: 10),
                      Text('End Date: $endDate', style: white16w400MediumTextStyle),
                      const SizedBox(height: 8),
                      Text('Device ID: ${deviceId()}', style: white16w400MediumTextStyle),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: const Text('Home'),
                leading: const Icon(Icons.home),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                ),
              ),
              ListTile(
                title: const Text('About Us'),
                leading: const Icon(Icons.details),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const InfoFolderPage(
                    title: 'About Us',
                    folderName: 'about_us', // the exact folder under Sigma/library/about_us
                    icon: Icons.info,
                    description: 'About our app, mission and goals.',
                  )));
                }
              ),
              ListTile(
                  title: const Text('Team'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InfoFolderPage(
                      title: 'Team',
                      folderName: 'sigma_team', // the exact folder under Sigma/library/about_us
                      icon: Icons.info,
                      description: 'Sigma Team',
                    )));
                  }
              ),
              ListTile(
                  title: const Text('FAQs'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InfoFolderPage(
                      title: 'FAQs',
                      folderName: 'faqs', // the exact folder under Sigma/library/about_us
                      icon: Icons.info,
                      description: 'Find answers to the most common questions about using the Sigma app.',
                    )));
                  }
              ),
              ListTile(
                  title: const Text('TERMS & CONDITIONS'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InfoFolderPage(
                      title: 'TERMS & CONDITIONS',
                      folderName: 'terms_conditions', // the exact folder under Sigma/library/about_us
                      icon: Icons.info,
                      description: 'Review the legal terms and policies governing your use of the Sigma app.',
                    )));
                  }
              ),
              ListTile(
                title: const Text('Library'),
                leading: const Icon(Icons.library_books),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LibraryHome()),
                ),
              ),
              ListTile(
                title: const Text('Real Time Monitoring Report'),
                leading: const Icon(Icons.monitor_heart),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StudyTrackerHomePage()),
                ),
              ),
              /*ListTile(
                title: const Text('Exam Preparation'),
                leading: const Icon(Icons.assignment),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExamPreparation()),
                ),
              ),*/
              ListTile(
                title: const Text('Exam Evaluation Bucket'),
                leading: const Icon(Icons.assessment),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EvaluationPage()),
                ),
              ),
             // Spacer(),
              Divider(height: 2,color: Colors.black,),
              Container(
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "$company",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
