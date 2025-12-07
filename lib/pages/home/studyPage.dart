import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/config/config.dart';
import 'package:sigma_new/config/config_loader.dart';
import 'package:sigma_new/models/menu_models.dart';
import 'package:sigma_new/pages/10thMh/10thmh.dart';
import 'package:sigma_new/supports/fetchDeviceDetails.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:intl/intl.dart';

import '../../utility/sd_card_utility.dart';
import '../../utility/sponsors_loader.dart';
import 'home_with_sponsors.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {


  List<String> courseList = [];
  List<SponsorItem> sponsors = [];


  @override
  void initState() {
    super.initState();
    sharedPrefrenceData();
  }

  sharedPrefrenceData() async {
    final prefs = await SharedPreferences.getInstance();

    String? course = prefs.getString('course');
    print("Standard${prefs.getString('StartDate')} State:${prefs.getString(
        'board')}");
    if (course != null && course.isNotEmpty) {
      courseList = course.split(","); // Convert String to List
    }
    print(courseList.length);
    print(courseList);

    setState(() {

    });
  }

  final repo = SponsorsRepository();

  @override
  Widget build(BuildContext context) {
    List<Menu> othersMenuList = [
      Menu(
          color: 0xFFFAEDCB, // Corrected color code
          imagePath: 'assets/svg/10_mh.svg',
          navigation: () {
            //  Get.to(StandardMenu(standard: "10th MH",));
          },
          title: '10th MH'),
      Menu(
          color: 0xFFC9E4DF,
          imagePath: 'assets/svg/12_mh.svg',
          navigation: () {
            //  Get.to(StandardMenu(standard: "12th MH",));
          },
          title: '12th MH PCM'),
      Menu(
          color: 0xFFC5DEF2,
          imagePath: 'assets/svg/jee_cet_neet.svg',
          navigation: () {
            // Get.to(StandardMenu(standard: "JEE",));
          },
          title: 'JEE CEE NEET'),
      Menu(
          color: 0xFFDBCDF0,
          imagePath: 'assets/svg/engg.svg',
          navigation: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("UI not defined in WireFrame"),
                duration: Duration(seconds: 2),
              ),
            );
          },
          title: 'Engineer'),

    ];
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              //height: MediaQuery.of(context).size.height-80.0,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.9,
              child: GridView.builder(
                shrinkWrap: true,
                // ✅ Important
                physics: NeverScrollableScrollPhysics(),
                // ❌ Disable internal scrolling
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 6,
                  childAspectRatio: 0.6,
                ),
                itemCount: courseList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          Config? config = await ConfigLoader
                              .getGlobalConfig(); // or your static class name

                          if (config == null) {
                            Get.snackbar(
                              "Config Error",
                              "Unable to load configuration file.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          try {
                            // Parse date
                            DateFormat formatter = DateFormat("dd-MM-yyyy");
                            DateTime now = DateTime.now();
                            DateTime start = formatter.parse(config.startDate!);
                            DateTime expiry = formatter.parse(
                                config.expiryDate!);

                            if (now.isBefore(start)) {
                              Get.snackbar(
                                "Access Denied",
                                "Course access begins on ${config.startDate}.",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (now.isAfter(expiry)) {
                              Get.snackbar(
                                "Access Expired",
                                "Course access expired on ${config.expiryDate}.",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            // Optional: Match Device ID; // Implement this or use MethodChannel
                            if (config.deviceID != deviceId()) {
                              Get.snackbar(
                                "Unauthorized Device",
                                "This device is not registered for access.",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            // Continue navigation
                            if (othersMenuList[index].navigation != null) {
                              othersMenuList[index].navigation!();
                              Get.to(StandardMenu(standard: courseList[index]));
                            } else {
                              print(
                                  'No navigation route defined for this menu item');
                            }
                          } catch (e) {
                            print("Validation failed: $e");
                            Get.snackbar(
                              "Error",
                              "Invalid date format or data.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.13,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(othersMenuList[index].color),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                const EdgeInsets.only(left: 63.0, top: 6),
                                child: SvgPicture.asset(
                                  'assets/svg/arrow.svg',
                                  // Correct interpolation
                                  height: 20,
                                  width: 20,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, left: 10.0, bottom: 5, right: 10),
                                child: SvgPicture.asset(
                                  othersMenuList[index]
                                      .imagePath, // Correct interpolation
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        courseList[index],
                        style: black14w400MediumTextStyle,
                      )
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ⭐ ADD SPONSORS HERE (NOW IT WILL DISPLAY)
          // simple: loader will fetch from SD and render SponsorsSection once ready
          SponsorsLoader(fetcher: () => repo.fetchSponsorsFromSdCard()),

        ],
      ),
    );
  }
}

