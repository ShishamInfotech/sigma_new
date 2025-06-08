import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/config/config.dart';
import 'package:sigma_new/pages/register/register_page.dart';
import 'package:sigma_new/pages/home/home.dart';
import 'package:sigma_new/supports/fetchDeviceDetails.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:sigma_new/config/config_loader.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List<String>? introImages;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initPermissions();
    loadIntroImages();
  }

  void _initPermissions() async {
    bool manageStorageGranted =
    await SdCardUtility.requestManageStoragePermission();
    if (!manageStorageGranted) {
      print("MANAGE_EXTERNAL_STORAGE permission not granted!");
    }
  }

  void loadIntroImages() async {
    introImages = await SdCardUtility.getIntroImages();
    setState(() {});
  }

  void _nextImage() {
    if (introImages == null || introImages!.isEmpty) return;

    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % introImages!.length;
    });
  }

  void _previousImage() {
    if (introImages == null || introImages!.isEmpty) return;

    setState(() {
      _currentImageIndex = (_currentImageIndex - 1) % introImages!.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 100),
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
          const SizedBox(height: 20),

          // Image display area with navigation controls
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (introImages != null && introImages!.isNotEmpty)
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(introImages![_currentImageIndex]),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        // Previous button
                        if (introImages!.length > 1)
                          Positioned(
                            left: 10,
                            child: IconButton(
                              icon: const Icon(Icons.chevron_left, size: 40),
                              onPressed: _previousImage,
                            ),
                          ),

                        // Next button
                        if (introImages!.length > 1)
                          Positioned(
                            right: 10,
                            child: IconButton(
                              icon: const Icon(Icons.chevron_right, size: 40),
                              onPressed: _nextImage,
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: AlertDialog(
                        title: const Text('Alert'),
                        content: Text(
                          'This device is not authorized, Please contact administrator \n Device Id - ${deviceId()}',
                          style: black16w400MediumTextStyle,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Page indicator
                if (introImages != null && introImages!.length > 1)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        introImages!.length,
                            (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? const Color(0xff7F0081)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Let's Start button
          Padding(
            padding: const EdgeInsets.only(bottom: 40, top: 20),
            child: SizedBox(
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
                  Config? config = await ConfigLoader.getGlobalConfig();
                  final prefs = await SharedPreferences.getInstance();

                  if (!prefs.containsKey('firstName')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
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
            ),
          ),
        ],
      ),
    );
  }
}