import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sigma_new/pages/register/register_page.dart';
import 'package:sigma_new/pages/home/home.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:sigma_new/config/config_loader.dart';

import '../../config/config.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List<String>? introImages;

  @override
  void initState() {
    super.initState();
    _initPermissions();
    loadIntroImages();
  }

  void _initPermissions() async {
    bool manageStorageGranted = await SdCardUtility.requestManageStoragePermission();
    if (!manageStorageGranted) {
      print("MANAGE_EXTERNAL_STORAGE permission not granted!");
      // Handle permission denial, e.g. show a dialog.
    }
  }
  void loadIntroImages() async {
    introImages = await SdCardUtility.getIntroImages();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 180),
          Center(
            child: Container(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                height: 90,
                width: 90,
                child: SvgPicture.asset('assets/svg/logo.svg'),
              ),
            ),
          ),
          const Text(
            "Learn anytime anywhere",
            style: black22RegularTextStyle,
          ),
          const SizedBox(height: 2),
          const Text(
            "Mini school in your pocket in the form of offline tablet",
            style: black12MediumTextStyle,
          ),
          // Display intro images (or videos) from sigma/intro
          introImages != null && introImages!.isNotEmpty
              ? SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: introImages!.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  child: Image.file(File(introImages![index])),
                );
              },
            ),
          )
              : Container(
            height: 300,
            child: const Center(child: CircularProgressIndicator()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7F0081),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                // Load global config to check registration status.
                Config? config = await ConfigLoader.getGlobalConfig();
                // For this example, we assume the device is registered if deviceID is non-empty.
                if (config == null ||
                    config.deviceID == null ||
                    config.deviceID!.isEmpty) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ));
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 10),
                  Text("Let's Start", style: white18MediumTextStyle),
                  Icon(Icons.arrow_forward_ios_outlined,
                      color: Colors.white, size: 24),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
