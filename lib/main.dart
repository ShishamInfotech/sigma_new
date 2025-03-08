import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sigma_new/pages/welcomePage/welcomePage.dart';
import 'package:sigma_new/supports/fetchDeviceDetails.dart';

void main() {
  runApp(const MyApp());
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
      home: const WelcomePage(),
    );
  }
}



