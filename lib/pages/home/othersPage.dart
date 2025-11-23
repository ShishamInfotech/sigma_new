import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart' as p;
import 'package:sigma_new/models/menu_models.dart';
import 'package:sigma_new/pages/exam_preparation/exam_preparation.dart';
import 'package:sigma_new/pages/home/quick_guide/quick_guide.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

import '../../utility/sd_card_utility.dart';
import '../pdf/PdfFolderListPage.dart';
import 'home_with_sponsors.dart';

class OtherPage extends StatefulWidget {
  const OtherPage({super.key});

  @override
  State<OtherPage> createState() => _Appbar2State();
}

class _Appbar2State extends State<OtherPage> {

  List<SponsorItem> sponsors = [];


  @override
  void initState() {
    super.initState();
    loadSponsors();
  }

  Future<void> loadSponsors() async {
    final items = await loadSponsorsFromSigmaLibrary();
    setState(() => sponsors = items);
  }

  Future<void> _openCalculator() async {
    try {
     // if (Platform.isAndroid) {
        // Try common calculator package names for Android
        const calculatorPackages = [
          'com.android.calculator2',          // Stock Android
          'com.google.android.calculator',    // Google Calculator
          'com.sec.android.app.popupcalculator',  // Samsung
          'com.coloros.calculator',          // Oppo
          'com.miui.calculator',             // Xiaomi
          'com.huawei.calculator',
          'com.google.android.calculator'// Huawei
        ];

        // Try each package until one works
        for (final package in calculatorPackages) {
          try {
            final intent = AndroidIntent(
              action: 'action_view',
              package: package,
              flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
            );
            await intent.launch();
            return; // If successful, exit the function
          } catch (e) {
            continue; // Try next package
          }
        }

        // If none of the specific packages worked, try the generic intent
        try {
          final intent = AndroidIntent(
            action: 'android.intent.action.MAIN',
            category: 'android.intent.category.APP_CALCULATOR',
          );
          await intent.launch();
          return;
        } catch (e) {
          // Fall through to URL launch
        }
     // }

      // Fallback for iOS or if Android methods failed
      const url = 'calculator://';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        return;
      }

      // Ultimate fallback - open app store to download a calculator
      if (Platform.isAndroid) {
        await launchUrl(
          Uri.parse('market://details?id=com.google.android.calculator'),
          mode: LaunchMode.externalApplication,
        );
      } else if (Platform.isIOS) {
        await launchUrl(
          Uri.parse('https://apps.apple.com/us/app/calculator/id1069511488'),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      // If everything fails, show a dialog with instructions
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Calculator Not Found'),
          content: const Text('Please open your device\'s calculator app manually.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    List<Menu> studyMenu = [
      Menu(
          color: 0xFFF2C6DF,
          imagePath: 'assets/svg/calculator.svg',
          navigation: () {
            _openCalculator();
          },
          title: 'Calculator'),
      Menu(
          color: 0xFFC5DEF2,
          imagePath: 'assets/svg/motivational_stories.svg',
          navigation: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                const PdfFolderListPage(title: 'Motivational Stories', folderName: 'motivationalstories',)));
          },
          title: 'Motivational Stories'),
      Menu(
          color: 0xFFC9E4DF,
          imagePath: 'assets/svg/logbook.svg',
          navigation: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                const PdfFolderListPage(title: 'Log Book', folderName: 'logbook',)));
          },
          title: 'Log Book'),
      Menu(
          color: 0xFFF8D9C4,
          imagePath: 'assets/svg/quick_guide.svg',
          navigation: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                const PdfFolderListPage(title: 'Quick Guide', folderName: 'quickguide',)));
          },
          title: 'Quick Guide'),
      Menu(
          color: 0xFFDBCDF0,
          imagePath: 'assets/svg/course_outline.svg',
          navigation: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                  const PdfFolderListPage(title: 'Course Outline', folderName: 'courseoutline',)));
          },
          title: 'Course Outline'),
      Menu(
          color: 0xFFFAEDCB,
          imagePath: 'assets/svg/exam_prep.svg',
          navigation: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                const PdfFolderListPage(title: 'Exam Preparation', folderName: 'examprep',)));
          },
          title: 'Exam Preparation'),
    ];
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: MediaQuery.of(context).size.width * 0.9,

                child: GridView.builder(
                  shrinkWrap: true,          // ✅ Important
                  physics: NeverScrollableScrollPhysics(), // ❌ Disable internal scrolling
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: studyMenu.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            if (studyMenu[index].navigation != null) {
                              studyMenu[index].navigation!();
                            }
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.13,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(studyMenu[index].color),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SvgPicture.asset(
                                studyMenu[index].imagePath,
                                height: 30,
                                width: 30,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          studyMenu[index].title,
                          textAlign: TextAlign.center,
                          style: black14w400MediumTextStyle,
                        )
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ⭐ ADD SPONSORS HERE (NOW IT WILL DISPLAY)
            SponsorsSection(
              sectionTitle: 'Our Sponsors',
              sponsors: sponsors,
            ),

          ],
        ),
      ),
    );

  }
}


/// Loads sponsor files from:   <SD Card base path> / library /
/// Example: /storage/emulated/0/Sigma/library
Future<List<SponsorItem>> loadSponsorsFromSigmaLibrary() async {
  try {
    // Get Sigma base path (your utility)
    final sigmaPath = await SdCardUtility.getBasePath();

    // Your sponsors directory: Sigma/library
    final baseDir = Directory("$sigmaPath/sponsors");

    if (!await baseDir.exists()) {
      print("⚠️ Sponsor directory not found: $baseDir");
      return [];
    }

    // Read all files inside the directory
    final entries = await baseDir.list().toList();

    final files = entries.whereType<File>().toList();

    // Optional: sort alphabetically
    files.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

    final sponsors = <SponsorItem>[];

    for (final file in files) {
      final ext = p.extension(file.path).toLowerCase();
      if (ext.isEmpty) continue;

      final type = guessTypeFromUrl(file.path);
      if (type == SponsorMediaType.unknown) {
        // Skip unsupported file types
        continue;
      }

      // Title = file name without extension
      final title = p.basenameWithoutExtension(file.path);

      // Local file URL (used by viewers)
      final url = "file://${file.path}";

      sponsors.add(
        SponsorItem(
          id: title,
          title: title,
          url: url,
          type: type,
        ),
      );
    }

    return sponsors;

  } catch (e) {
    print("ERROR while reading sponsors: $e");
    return [];
  }
}
