import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/config/config.dart';
import 'package:sigma_new/pages/register/register_page.dart';
import 'package:sigma_new/pages/home/home.dart';
import 'package:sigma_new/supports/fetchDeviceDetails.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:sigma_new/config/config_loader.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

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
    bool manageStorageGranted =
        await SdCardUtility.requestManageStoragePermission();
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
                      /*String filePath = introImages![index];
                if (_isVideo(filePath)) {
                  return Container(
                    margin: const EdgeInsets.all(8),
                    width: 200,
                    height: 300,
                    child: Chewie(
                      controller: ChewieController(
                        videoPlayerController: VideoPlayerController.file(File(filePath)),
                        autoPlay: true,
                        looping: true,
                        showControls: true,
                      ),
                    )
                  );
                } else {*/
                      return Container(
                        margin: const EdgeInsets.all(8),
                        child: Image.file(File(introImages![index])),
                      );
                    },
                  ),
                )
              : Container(
                  height: 300,
                  child: Center(
                      child: AlertDialog(
                    title: const Text('Alert'),
                    content: Text(
                        'This device is not authorized, Please contact administrator \n Device Id - ${deviceId()}',
                        style: black16w400MediumTextStyle),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  )),
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
                print(deviceId());
                print('Config ${config!.deviceID}');
                // config.deviceID="d6f9ffb0990d2843";
                /*if (config.deviceID != deviceId()) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Alert'),
                        content: Text(
                            'This device is not authorized, Please contact administrator \n Device Id - ${deviceId()}'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {*/

                final prefs = await SharedPreferences.getInstance();
                Get.snackbar("Error", " ${prefs.containsKey('firstName')}");
                print(prefs.containsKey('firstName'));
                // For this example, we assume the device is registered if deviceID is non-empty.
                if (!prefs.containsKey('firstName')) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ));
                } else {
                  // print("Data ${await SdCardUtility.getSubjectEncJsonData("sigma_data.json")}");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ));
                }
                // }
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

  bool _isVideo(String path) {
    return path.toLowerCase().endsWith('.mp4') ||
        path.toLowerCase().endsWith('.mov') ||
        path.toLowerCase().endsWith('.avi');
  }
}
