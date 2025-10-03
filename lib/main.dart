import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sigma_new/pages/splashscreen/splash_screen.dart';
import 'package:sigma_new/pages/usage_report/usage_report_page.dart';
import 'package:sigma_new/pages/welcomePage/welcomePage.dart';
import 'package:sigma_new/supports/fetchDeviceDetails.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';  // ✅ Required
import 'package:sigma_new/utility/crypto_exception.dart'; // ✅ If you're catching CryptoException

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {

   /* if(requestStoragePermission()==true ||requestAllFileAccessPermission()==true){

    }*/

    //await requestStoragePermission();
    await requestAllFileAccessPermission();


    // 🔹 Create bind files if first time
   //await SdCardUtility.initializeBindingIfNeeded();

    // Validate SD card binding
   //await SdCardUtility.validateBinding();

    // Start app if validation succeeds
    runApp(const MyApp());
    AppUsageTracker.startTracking();
    AppUsageTracker.startAutoSave();

    // Initialize app tracking only after successful binding

  } catch (e) {
    // If validation fails, show error screen
    print("Failed to pick folder: ${e}");
    runApp(ErrorScreen(errorMessage: e.toString()));
  }
}

Future<void> requestStoragePermission() async {
  final status = await Permission.storage.request();
  if (!status.isGranted) {
    throw Exception("Storage permission denied.");
  }
}

Future<void> requestAllFileAccessPermission() async {
  final status = await Permission.manageExternalStorage.request();
  if (!status.isGranted) {
    throw Exception("All file access permission denied");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FatchDeviceDetails().init();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      localizationsDelegates: [
        FlutterQuillLocalizations.delegate,
      ],
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String errorMessage;

  const ErrorScreen({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}



