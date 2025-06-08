import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../welcomePage/welcomePage.dart';
 // Import your welcome page

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to welcome page after 2 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or your preferred background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo
            SizedBox(
              height: 150,
              width: 150,
              child: SvgPicture.asset('assets/svg/logo.svg'),
            ),
            const SizedBox(height: 20),
            // Optional loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff7F0081)),
            ),
          ],
        ),
      ),
    );
  }
}